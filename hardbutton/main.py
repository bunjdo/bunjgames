import asyncio
import argparse as argparse
import netifaces
import websockets
import socket
import json
from concurrent.futures import ThreadPoolExecutor
from typing import Tuple, Union
import ssl


class GameHandler:

    STATE_INITIAL = 'initial'
    STATE_SETUP = 'setup'
    STATE_READY = 'ready'

    def __init__(self, game_name, token, url, setup_required):
        self.websocket = None
        self.state = self.STATE_INITIAL
        self._game_name = game_name
        self._token = token
        self._setup_required = setup_required
        if self._game_name == 'weakest':
            self._button_method_name = 'save_bank'
        else:
            self._button_method_name = 'button_click'
        self._url = url
        self._players = {}
        self._ip_to_player_id_binding = {}
        self.player_to_setup = None

    def _generate_button_click_params(self, player_id):
        if self._game_name == 'weakest':
            return dict()
        else:
            return dict(player_id=player_id)

    @property
    def websocket_url(self):
        return f'{self._url}{"" if self._url.endswith("/") else "/"}{self._game_name}/ws/{self._token}'

    def _check_unassigned_players(self, force_message=False):
        if not self._setup_required:
            self.player_to_setup = None
            if self.state != self.STATE_READY:
                print('Setup is not required')
            self.state = self.STATE_READY
            return
        if all(player_id in self._ip_to_player_id_binding.values() for player_id in self._players.keys()):
            if self.state != self.STATE_READY:
                self.player_to_setup = None
                self.state = self.STATE_READY
                print('Great! All players are assigned to buttons')
        elif self.state != self.STATE_SETUP or force_message:
            self.state = self.STATE_SETUP
            for player_id, player in self._players.items():
                if player_id not in self._ip_to_player_id_binding.values():
                    self.player_to_setup = player
                    print(f'Waiting for player {player["name"]} to push the button')
                    break

    def _on_players(self, players):
        self._players = players
        self._check_unassigned_players()

    def on_websocket_message(self, type, message):
        if type == 'game':
            players_from_message = {
                player['id']: player for player in message['players']
            }
            self._on_players(players_from_message)
        elif type == 'error':
            print(f'Error: {message}')

    def on_upd_message(self, message):
        if self.state != self.STATE_READY:
            if self.player_to_setup:
                self._ip_to_player_id_binding[message] = self.player_to_setup['id']
                print(f'Player {self.player_to_setup["name"]} assigned to button {message}')
                self.player_to_setup = None
                self._check_unassigned_players(force_message=True)
        else:
            if not self._setup_required:
                player_id = int(message)
            else:
                player_id = self._ip_to_player_id_binding.get(message)
            player = self._players.get(player_id) if player_id else None
            if player is not None and self.websocket:
                print(f'Button click from player {player["name"]} ({message})')
                asyncio.ensure_future(self.websocket.send(json.dumps(dict(
                    method=self._button_method_name,
                    params=self._generate_button_click_params(player_id)
                ))))
            elif self.websocket:
                print(f'Button click from unknown player ({message})')


async def websocket_handler(event_loop, game_handler):
    while True:
        print(f'Connecting to {game_handler.websocket_url}...')
        ssl_obj = None
        if game_handler.websocket_url.startswith('wss://'):
            ssl_obj = ssl._create_unverified_context()
        async with websockets.connect(game_handler.websocket_url, ssl=ssl_obj) as websocket:
            game_handler.websocket = websocket
            print(f'Connected to {game_handler.websocket_url}')
            while True:
                payload = json.loads(await websocket.recv())
                game_handler.on_websocket_message(payload['type'], payload['message'])
        game_handler.websocket = None


class BroadcastProtocol(asyncio.DatagramProtocol):

    def __init__(
            self, target: Tuple[str, int], game_handler: GameHandler, *, event_loop: asyncio.AbstractEventLoop = None
    ):
        self.game_handler = game_handler
        self.target = target
        self.loop = asyncio.get_event_loop() if event_loop is None else event_loop

    def connection_made(self, transport: asyncio.transports.DatagramTransport):
        print(f'Started button listener at {self.target[0]}:{self.target[1]}')
        self.transport = transport
        sock = transport.get_extra_info("socket")
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

    def datagram_received(self, data: Union[bytes, str], addr: Tuple[str, int]):
        message = data if isinstance(data, str) else data.decode("utf-8")
        self.game_handler.on_upd_message(message)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument('--version', action='version', version='v0.2.0')

    parser.add_argument("--game", help="game type", type=str)
    parser.add_argument("--token", help="game token", type=str)

    parser.add_argument("--url", help="websocket url", type=str, default='wss://api.games.bunj.app/')

    parser.add_argument("--broadcast_addr", type=str)
    parser.add_argument("--local_addr", type=str, default='0.0.0.0:9009')

    parser.add_argument("--setup_required", type=bool, default=False)

    args = parser.parse_args()

    broadcast_addr = args.broadcast_addr
    if not broadcast_addr:
        gws = netifaces.gateways()
        gateway_ip, interface = gws['default'][netifaces.AF_INET]
        bits = gateway_ip.split('.')
        broadcast_addr = f'{bits[0]}.{bits[1]}.{bits[2]}.255:9009'
        print(f'Selecting broadcast address: {broadcast_addr}')

    game_handler = GameHandler(args.game, args.token, args.url, args.setup_required)

    executor = ThreadPoolExecutor(2)
    event_loop = asyncio.get_event_loop()

    event_loop.create_task(websocket_handler(event_loop, game_handler))

    broadcast_ip, broadcast_port = broadcast_addr.split(':')
    local_ip, local_port = args.local_addr.split(':')

    udp_task = event_loop.create_datagram_endpoint(
        lambda: BroadcastProtocol(
            (broadcast_ip, int(broadcast_port)), game_handler, event_loop=event_loop
        ),
        local_addr=(local_ip, int(local_port))
    )
    event_loop.create_task(udp_task)

    try:
        event_loop.run_forever()
    except KeyboardInterrupt:
        print(f'Exiting...')
