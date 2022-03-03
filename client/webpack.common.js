const webpack = require('webpack');
const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const PACKAGE = require('./package.json');

const src = (uri) => path.resolve(__dirname, `src/${uri}`);

module.exports = {
  entry: [
    './src/App.jsx',
    './src/App.scss',
  ],
  output: {
    path: path.join(__dirname, 'public'),
    filename: 'bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        options: {
            presets:["@babel/preset-env", "@babel/preset-react"]
        }
      },
      {
        test: /\.scss$/,
        use: [
            'style-loader',
            {loader: 'css-loader', options: { modules: true }},
            'sass-loader'
        ]
      },
      {
        test: /\.css$/i,
        use: ['style-loader', 'css-loader'],
      },
    ]
  },
  resolve: {
    alias: {
      common: src('common'),
      core: src(''),
      info: src('info'),
      whirligig: src('whirligig'),
      jeopardy: src('jeopardy'),
      weakest: src('weakest'),
      feud: src('feud'),
    },
    extensions: ['.js', '.jsx']
  },
  plugins:[
    new webpack.DefinePlugin({
      MEDIA_ENDPOINT: JSON.stringify(process.env.REACT_APP_MEDIA_ENDPOINT || "/media/"),
      API_ENDPOINT: JSON.stringify(process.env.REACT_APP_API_ENDPOINT || "/api/"),
      WS_ENDPOINT: JSON.stringify(process.env.REACT_APP_WS_ENDPOINT || "/ws/"),
    }),
    new MiniCssExtractPlugin({
      filename: '[name].css',
      chunkFilename: '[id].css',
    }),
  ],
  devServer: {
    contentBase: path.join(__dirname, 'public'),
    hot: true,
    historyApiFallback: {
      index: 'index.html'
    },
    disableHostCheck: true,
  }
};
