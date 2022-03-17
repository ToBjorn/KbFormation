var path = require('path'),
  MiniCssExtractPlugin = require('mini-css-extract-plugin'),
  CssMinimizerPlugin = require('css-minimizer-webpack-plugin')

module.exports = {
  entry: './index.js',
  output: {
    path: path.join(__dirname, '../priv/static'),
    filename: '[name].js',
  },
  //...
  //This will bundle all our .css file inside styles.css
  optimization: {
    splitChunks: { cacheGroups: { styles: { name: 'styles', test: /\.css$/, chunks: 'all', enforce: true } } },
    minimizer: [`...`, new CssMinimizerPlugin()]
  },
  plugins: [new MiniCssExtractPlugin({ insert: "", filename: "[name].css" })],
  mode: 'production',
  module: {
    rules: [
      {
        test: /.js?$/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: [
              ["@babel/preset-env", { "targets": "defaults" }],
              "@babel/preset-react",
              ["jsxz", { dir: 'tonys.webflow' }] 
            ]
          }
        },
        exclude: /node_modules/
      },
      //...
      //Add to our loader rules
      //This will process the .css files included in our application (app.js)
      {
        test: /\.(css)$/,
        use: [{ loader: MiniCssExtractPlugin.loader }, { loader: "css-loader" }]
      }
    ]
  }
};