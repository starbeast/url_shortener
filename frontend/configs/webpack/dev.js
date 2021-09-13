// development config
const { merge } = require("webpack-merge");
const commonConfig = require("./common");
const fs = require("fs");
const childProcess = require("child_process");

const setupSSLCertificates = () => {
  try {
    if (!fs.existsSync("config/ssl/")) {
      fs.mkdirSync("config/ssl");
    }
    if (!fs.existsSync("config/ssl/ca.crt")) {
      console.log("Generating local development CA certificate...");
      childProcess.execSync("openssl genrsa -out config/ssl/ca.key 4096");
      childProcess.execSync(
        'openssl req -x509 -new -nodes -subj "/C=US/ST=MA/O=MobileMonkey, Inc./CN=MobileMonkey Local Dev CA" -key config/ssl/ca.key -sha256 -days 3650 -out config/ssl/ca.crt',
      );
      console.warn(
        "\x1b[1m\x1b[44m\x1b[37mTo avoid SSL errors in your browser, please configure your PC to trust the CA certificate (ca.crt) located in config/ssl/\x1b[0m",
      );
    }
    if (!fs.existsSync("config/ssl/server.crt")) {
      childProcess.execSync("openssl genrsa -out config/ssl/server.key 2048");
      childProcess.execSync(
        "openssl req -new -sha256 -key config/ssl/server.key -out config/ssl/server.csr -config config/openssl-server-crt.conf",
      );
      childProcess.execSync(
        "openssl x509 -req -in config/ssl/server.csr -CA config/ssl/ca.crt -CAkey config/ssl/ca.key -CAcreateserial -out config/ssl/server.crt -days 3650 -sha256 -extensions v3_req -extfile config/openssl-server-crt.conf",
      );
    }
    return {
      https: {
        key: fs.readFileSync("config/ssl/server.key"),
        cert: fs.readFileSync("config/ssl/server.crt"),
        ca: fs.readFileSync("config/ssl/ca.crt"),
      },
    };
  } catch (e) {
    return { https: true };
  }
};

module.exports = merge(commonConfig, {
  mode: "development",
  entry: [
    "react-hot-loader/patch", // activate HMR for React
    "webpack-dev-server/client?http://localhost:3001", // bundle the client for webpack-dev-server and connect to the provided endpoint
    "./index.tsx", // the entry point of our app
  ],
  devServer: {
    port: 3001,
    hot: "only", // enable HMR on the server
    historyApiFallback: true, // fixes error 404-ish errors when using react router :see this SO question: https://stackoverflow.com/questions/43209666/react-router-v4-cannot-get-url
    https: true,
    ...setupSSLCertificates(),
  },
  devtool: "cheap-module-source-map",
  plugins: [],
});
