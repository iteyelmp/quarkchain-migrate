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
        <p class="convert-title">Tokens</p>
        <div class="convert-value-layout convert-value">
          <p class="convert-value-old">{{ this.oldBalStr }}</p>
          <svg xmlns="http://www.w3.org/2000/svg" width="13" height="12" viewBox="0 0 13 12" fill="none">
            <path
                d="M10.1026 5.4722L6.71056 2.0802L7.60656 1.2002L12.5826 6.1762L7.60656 11.1522L6.71056 10.2562L10.1026 6.8802H0.726562V5.4722H10.1026Z"
                fill="#2F3CC3"/>
          </svg>
          <p class="convert-value-new">{{ this.newBalStr }}</p>
          QKC
        </div>
      </div>

      <div class="row-layout convert-margin">
        <p class="convert-title">Wallet</p>
        <div class="convert-value">
          {{ this.accountStr }}
        </div>
      </div>

      <div class="convert-margin">
        <button class="convert-button" @click="clickButton">{{ buttonStr }}</button>
      </div>
    </div>
  </div>
</template>

<script>
import {ethers} from 'ethers';
import {connectWallet} from "@/utils/walletManager";

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
        return "Connect"
      }
      if(this.oldBalance === 0n) {
        return "You don't have any QKC tokens";
      }
      return "Convert";
    },

    contract() {
      if (this.$store.state.chainConfig && this.$store.state.chainConfig.chainID) {
        const {FileBoxController} = this.$store.state.chainConfig;
        return FileBoxController;
      }
      return null;
    },
    flatDirectory() {
      if (this.$store.state.chainConfig && this.$store.state.chainConfig.chainID) {
        const {FlatDirectory} = this.$store.state.chainConfig;
        return FlatDirectory;
      }
      return null;
    },
  },
  methods: {
    clickButton() {
      if (!this.account) {
        connectWallet(this.$message);
        return;
      }
    }
  }
}
</script>

<style scoped lang="scss">
.home-container {
  width: 750px;
  margin: 80px auto;
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
  opacity: 0.6;
  margin-bottom: 3px;
  text-align: left;
  border: 1px solid rgba(24, 30, 169, 0.6);
}

.home-convert {
  margin-top: 25px;
  padding: 25px 35px;
  border: 1px solid rgba(24, 30, 169, 0.3);

  .row-layout {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
  }

  .convert-margin {
    margin-top: 25px;
  }

  .convert-title {
    font-family: AktivGroteskEx;
    font-weight: bold;
    letter-spacing: 1px;
    color: rgb(23, 34, 162);
    font-size: 22px;
    line-height: 28px;
  }

  .convert-value-layout {
    display: flex;
    flex-direction: row;
    justify-content: space-around;
    align-items: center;
    gap: 8px;
  }
  .convert-value {
    font-family: "Roboto Mono";
    font-weight: normal;
    margin-left: auto;
    text-align: right;
    color: rgb(23, 34, 162);
    font-size: 18px;
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
    margin-left: 32px;
    border-radius: 4px;
    padding: 16px 24px;
  }
  .convert-button:hover {
    background-color: rgba(24, 30, 169, 0.7);
    border: 0;
  }
}
</style>
