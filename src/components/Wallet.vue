<template>
  <div id="wallet">
    <button
      class="btn-connect"
      v-if="!this.account"
      @click.stop="connect"
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
import { mapState } from 'vuex';
import { connectWallet } from '@/utils/walletManager';

export default {
  name: 'WalletComponent',
  computed: {
    ...mapState(['account']),
    accountShort() {
      if (!this.account) return null;
      return this.account.substring(0, 6) + '...' + this.account.slice(-4);
    }
  },
  methods: {
    connect() {
      connectWallet(this.$message);
    }
  }
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
  border-radius: 4px;
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
