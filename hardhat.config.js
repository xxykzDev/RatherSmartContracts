require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

const { PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

const API_URL_SEPOLIA = `https://sepolia.infura.io/v3/6ad32fe8f2d64de4b501ab527cc49740`;

module.exports = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true, // Habilita la optimización
        runs: 200, // El número de ejecuciones debe coincidir con lo que Etherscan espera
      },
    },
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    sepolia: {
      url: API_URL_SEPOLIA,
      accounts: [PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};
