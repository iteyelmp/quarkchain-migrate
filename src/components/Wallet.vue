<template>
  <div id="wallet">
    <button
      class="btn-connect"
      v-if="!this.currentAccount"
      @click.stop="connectWallet"
    >
      Connect
    </button>
    <div v-else class="account">
      {{ this.accountShort }}
      &nbsp;|&nbsp;
      {{ "Ethereum" }}
    </div>
  </div>
</template>

<script>
import { mapActions } from "vuex";
import { chains } from '@/store/state';

const chain = 3335;
const chainID = `0x${chain.toString(16)}`;

export default {
  name: "WalletComponent",
  props: {},

  data: () => ({
    networkId: chain,
    currentAccount: null,
  }),
  async created() {
    this.connectWallet();
    window.ethereum.on("chainChanged", this.handleChainChanged);
    window.ethereum.on("accountsChanged", this.handleAccountsChanged);
  },
  computed: {
    accountShort() {
      return (
        this.currentAccount.substring(0, 6) +
        "..." +
        this.currentAccount.substring(
          this.currentAccount.length - 4,
          this.currentAccount.length
        )
      );
    },
  },
  methods: {
    ...mapActions(["setChainConfig", "setAccount"]),
    connectWallet() {
      if (!window.ethereum) {
        this.$message.error('Can\'t setup the Network because window.ethereum is undefined');
        return;
      }
      this.login();
    },
    async handleChainChanged() {
      const newChainId = await window.ethereum.request({ method: "eth_chainId" });
      if (chainID !== newChainId) {
        this.currentAccount = null;
        this.setAccount(null);
        this.setChainConfig({});
      } else {
        const c = chains.find((v) => v.chainID === chainID);
        this.setChainConfig(JSON.parse(JSON.stringify(c)));
        if (!this.currentAccount) {
          await this.login();
        }
      }
    },
    async handleAccountsChanged(accounts) {
      // account
      if (accounts.length === 0) {
        this.currentAccount = null;
        this.setAccount(null);
        console.warn(
          "MetaMask is locked or the user has not connected any accounts"
        );
        return;
      }
      if (accounts[0] !== this.currentAccount) {
        this.currentAccount = accounts[0];
        this.setAccount(accounts[0]);
      }
    },
    async login() {
      try {
        const currentChainId = await window.ethereum.request({ method: 'eth_chainId' });
        if (currentChainId !== chainID) {
          await window.ethereum.request({
            method: 'wallet_switchEthereumChain',
            params: [{ chainId: chainID }],
          });
        }

        const accounts = await window.ethereum.request({
          method: 'eth_requestAccounts',
        });
        this.handleAccountsChanged(accounts);
      } catch (error) {
        if (error.code === 4001) {
          this.$message.error('User rejected');
        } else {
          this.$message.error('Connect Error: ' + error.message);
        }
      }
    },
  },
};
</script>

<style scoped>
#wallet {
  display: flex;
  justify-content: center;
}

.btn-connect {
  cursor: pointer;
  transition: all 0.1s ease 0s;
  width: 120px;
  height: 44px;
  color: #ffffff;
  font-size: 18px;
  border: 0;
  background: rgb(24, 30, 169);
  border-radius: 36px;
}
.btn-connect:hover {
  background-color: rgba(24, 30, 169, 0.7);
  border: 0;
}

.account {
  height: 38px;
  font-size: 15px;
  line-height: 38px;
  background: #FFFFFF;
  border: 1px solid #6D71CB;
  color: #1722a2;
  padding: 0 15px;
  text-align: center;
}
</style>
