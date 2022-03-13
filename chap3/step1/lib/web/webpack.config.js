module.exports = {
    entry: './script.js',
    output: { filename: 'bundle.js' },
    plugins: [],
    mode: 'none',
    module: {
      rules: [
        {
          test: /.js?$/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: [
                ["@babel/preset-env", { "targets": "defaults" }],
                "@babel/preset-react"
              ]
            }
          },
          exclude: /node_modules/
        }
      ]
    },
  };