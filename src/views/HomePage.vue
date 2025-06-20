<template>
  <div class="home-container">
    <p class="home-title">QuarkChain ERC20 Token Migration</p>
    <div class="home-message">
      <p>
        To seamlessly integrate QuarkChain with Ethereum’s rollup infrastructure, the original ERC-20 QKC token (L1)
        needs to be migrated to a new ERC-20 QKC token (L2) at a 1:1 ratio.
      </p>

      <p style="margin-top: 15px">
        This new token will replace the existing one and serve as the official bridge token between Ethereum and
        QuarkChain Layer 2. For more details, please visit
        <a target="_blank" class="message-a"
           href="https://snapshot.box/#/s:quarkchain-org.eth/proposal/0x9480eb4b37541a6bb60df4975def4adf61fe988f81e7965e539cd58d19a55d47">
          this link
        </a>.
      </p>
    </div>
    <div class="home-convert">
      <div class="row-layout">
        <p class="convert-title">QKC (L1)</p>
        <div class="convert-value convert-value-old">
          {{ this.oldBalStr }} QKC
        </div>
      </div>

      <div class="row-layout convert-margin">
        <p class="convert-title">QKC (L2)</p>
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
        <el-button
            class="convert-button"
            @click="clickButton"
            :loading="isLoading"
            :disabled="isButtonDisabled">
          {{ buttonStr }}
        </el-button>
      </div>
    </div>
  </div>
</template>

<script>
import {ethers} from 'ethers';
import {connectWallet} from "@/utils/walletManager";
import {approveErc20, convert, getErc20Allowance, getErc20Balance, getL2QKCBalance} from "@/utils/web3";

export default {
  data() {
    return {
      oldBalance: 0n,
      newBalance: 0n,
      allowance: 0n,
      isFetching: false,
      isLoading: false
    }
  },
  computed: {
    account() {
      return this.$store.state.account;
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
        return "You don't have any QKC (L1) tokens";
      }
      if (this.allowance < this.oldBalance) {
        return "Approve";
      }
      return "Convert";
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
    isButtonDisabled() {
      return !!this.account && this.oldBalance <= 0n;
    },

    Conversion() {
      return this.$store.state.chainConfig?.Conversion || null;
    },
    OldToken() {
      return this.$store.state.chainConfig?.OldToken || null;
    },
    L2Rpc() {
      return this.$store.state.chainConfig?.L2Rpc || null;
    },
    accountAndTokensReady() {
      return !!(this.account && this.OldToken && this.L2Rpc);
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
      if (this.isFetching) {
        console.log("Skip fetch: already in progress");
        return;
      }
      this.isFetching = true;
      try {
        const [oldToken, newToken, allowance] = await Promise.all([
          getErc20Balance(this.OldToken, this.account),
					getL2QKCBalance(this.L2Rpc, this.account),
          getErc20Allowance(this.OldToken, this.account, this.Conversion)
        ]);
        this.oldBalance = oldToken;
        this.newBalance = newToken;
        this.allowance = allowance;
      } finally {
        this.isFetching = false;
      }
    },
    async clickButton() {
      if (!this.account) {
        await connectWallet(this.$message);
        return;
      }
      if (this.oldBalance <= 0n) {
        return;
      }

      const runWithLoading = async (fn, successMsg) => {
        this.isLoading = true;
        try {
          await fn();
          if (successMsg) this.$message.success(successMsg);
        } catch (error) {
          console.error(error);
          this.$message.error("An unexpected error occurred.");
        } finally {
          this.isLoading = false;
          await this.fetchBalances();
        }
      };

      if (this.allowance < this.oldBalance) {
        // approve
        await runWithLoading(
            () => approveErc20(this.OldToken, this.Conversion),
            "Approval successful!"
        );
        return;
      }

      await runWithLoading(
          () => convert(this.Conversion),
          "Conversion completed successfully!"
      );
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
  padding: 22px 35px;
  font-style: normal;
  font-weight: 400;
  font-size: 15px;
  line-height: 19px;
  color: rgb(24, 30, 169);
  opacity: 0.8;
  margin-bottom: 3px;
  text-align: left;
  border: 1px solid rgba(24, 30, 169, 0.6);

  .message-a {
    text-decoration: underline;
    background: transparent;

    &:hover {
      color: #648BFD;
    }
  }

}

.home-convert {
  margin-top: 25px;
  padding: 22px 35px;
  border: 1px solid rgba(24, 30, 169, 0.3);

  .row-layout {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
  }

  .convert-margin {
    margin-top: 18px;
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

@media screen and (max-width: 500px) {
  .home-container {
    width: 95%;
    margin: 20px auto;
    padding: 0;
  }

  .home-title {
    font-size: 16px;
    line-height: 20px;
    margin-bottom: 14px;
  }

  .home-message {
    padding: 15px 24px;
    font-size: 14px;
    margin-top: 25px;
  }

  .home-convert {
    padding: 15px 24px;

    .convert-title {
      font-size: 15px;
    }

    .convert-value {
      font-size: 14px;
    }

    .convert-button {
      width: 100%;
      font-weight: 350;
      font-size: 12px;
      line-height: 15px;
      letter-spacing: 1px;
      padding: 16px 5px;
    }
  }
}
</style>s
