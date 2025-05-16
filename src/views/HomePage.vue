<template>
  <div class="home-container">
    <p class="home-title">QuarkChain Token Migrator</p>
    <p class="home-message">
      Migrate your Old QKC tokens to New QKC tokens at a 1:1 ratio starting Dec 20, 2025 18:00. Migration will end on
      Dec 20, 2025 18:00. View your QKC balance, and complete the migration before the deadline. If you need help, visit
      our FAQ or contact support.
    </p>
    <div class="home-convert">
      <div class="row-layout">
        <p class="convert-title">QKC (v1)</p>
        <div class="convert-value convert-value-old">
          {{ this.oldBalStr }} QKC
        </div>
      </div>

      <div class="row-layout convert-margin">
        <p class="convert-title">QKC (v2)</p>
        <div class="convert-value convert-value-new">
          {{ this.newBalStr }} QKC
        </div>
      </div>

      <div class="row-layout convert-margin">
        <p class="convert-title">Address</p>
        <div class="convert-value">
          {{ this.accountStr }}
        </div>
      </div>

      <div class="convert-margin">
        <button class="convert-button" @click="clickButton" :disabled="isButtonDisabled">
          {{ buttonStr }}
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import {ethers} from 'ethers';
import {connectWallet} from "@/utils/walletManager";
import {getErc20Balance} from "@/utils/web3";

export default {
  data() {
    return {
      oldBalance: 0n,
      newBalance: 0n,
    }
  },
  computed: {
    account() {
      return this.$store.state.account;
    },
    accountStr() {
      if (this.account) {
        return this.account.substring(0, 6) + "..." + this.account.substring(
            this.account.length - 4,
            this.account.length
        )
      } else {
        return "-";
      }
    },
    oldBalStr() {
      if (this.account) {
        return parseFloat(ethers.formatEther(this.oldBalance)).toFixed(2);
      } else {
        return "0.00";
      }
    },
    newBalStr() {
      if (this.account) {
        return parseFloat(ethers.formatEther(this.newBalance)).toFixed(2);
      } else {
        return "0.00";
      }
    },
    buttonStr() {
      if (!this.account) {
        return "Connect Wallet"
      }
      if (this.oldBalance === 0n) {
        return "You don't have any QKC tokens";
      }
      return "Convert";
    },

    isButtonDisabled() {
      return this.account || this.oldBalance > 0n;
    },

    Conversion() {
      return this.$store.state.chainConfig?.Conversion || null;
    },
    OldToken() {
      return this.$store.state.chainConfig?.OldToken || null;
    },
    NewToken() {
      return this.$store.state.chainConfig?.NewToken || null;
    },
    accountAndTokensReady() {
      return !!(this.account && this.OldToken && this.NewToken);
    }
  },
  watch: {
    accountAndTokensReady: {
      immediate: true,
      handler(ready) {
        if (ready) {
          this.fetchBalances();
        }
      }
    },
  },
  methods: {
    async fetchBalances() {
      if (!this.account) {
        return;
      }
      const [oldToken, newToken] = await Promise.all([
        getErc20Balance(this.OldToken, this.account),
        getErc20Balance(this.NewToken, this.account),
      ]);
      this.oldBalance = oldToken;
      this.newBalance = newToken;
    },
    clickButton() {
      if (!this.account) {
        connectWallet(this.$message);
        return;
      }
      if (this.oldBalance <= 0n) {
        return;
      }
    }
  },
  mounted() {
    this.fetchBalances();
    this.timer = setInterval(this.fetchBalances, 30000);
  },
  beforeDestroy() {
    clearInterval(this.timer);
  },
}
</script>

<style scoped lang="scss">
.home-container {
  width: 750px;
  margin: 60px auto;
  padding: 25px;
}

.home-title {
  font-weight: bold;
  color: rgb(23, 34, 162);
  font-size: 20px;
  line-height: 26px;
  letter-spacing: 2px;
  margin-bottom: 14px;
  text-transform: uppercase;
  font-family: AktivGroteskEx;
}

.home-message {
  padding: 25px 35px;
  font-style: normal;
  font-weight: 400;
  font-size: 14px;
  line-height: 18px;
  color: rgb(24, 30, 169);
  opacity: 0.8;
  margin-bottom: 3px;
  text-align: left;
  border: 1px solid rgba(24, 30, 169, 0.6);
}

.home-convert {
  margin-top: 25px;
  padding: 24px 35px;
  border: 1px solid rgba(24, 30, 169, 0.3);

  .row-layout {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
  }

  .convert-margin {
    margin-top: 14px;
  }

  .convert-title {
    font-family: AktivGroteskEx;
    font-weight: bold;
    letter-spacing: 1px;
    color: rgb(23, 34, 162);
    font-size: 16px;
    line-height: 16px;
  }

  .convert-value {
    font-family: "Roboto Mono";
    font-weight: normal;
    margin-left: auto;
    text-align: right;
    color: rgb(23, 34, 162);
    font-size: 16px;
    line-height: 26px;
  }
  .convert-value-old {
    color: #F4A261;
  }
  .convert-value-new {
    color: #3B4BFF;
  }

  .convert-button {
    cursor: pointer;
    width: 65%;
    font-weight: 500;
    background: rgb(24, 30, 169);
    border: none;
    font-size: 15px;
    line-height: 13px;
    letter-spacing: 2px;
    text-transform: uppercase;
    color: rgb(255, 255, 255);
    border-radius: 4px;
    padding: 16px 24px;
  }
  .convert-button:hover {
    background-color: rgba(24, 30, 169, 0.7);
    border: 0;
  }
  .convert-button:disabled {
    background: rgba(24, 30, 169, 0.4);
    color: rgba(255, 255, 255, 0.8);
    cursor: not-allowed;
  }
}
</style>
