<template>
  <div class="home-container">
    <p class="home-title">QuarkChain Token Migrator</p>
    <p class="home-message">
      Migrate your Old QKC tokens to New QKC tokens at a 1:1 ratio starting Dec 20, 2025 18:00. Migration will end on Dec 20, 2025
      18:00. View your QKC balance, and complete the migration before the deadline. If you need help, visit our FAQ or
      contact support.
    </p>
    <div class="home-convert">
      <div class="row-layout">
        <p class="convert-title">Tokens</p>
        <div class="convert-value">
          <p class="Balance__Amount-sc-5daqr5-3 NewTokensBalance__TokenAmount-sc-1vc5eu9-3 gyKhVi">0.0000</p>
        </div>
      </div>
      <div class="row-layout convert-margin">
        <p class="convert-title">Wallet</p>
        <div class="convert-value">
          0x7727...4285
        </div>
      </div>
      <div class="convert-margin">
        <button class="convert-button">You don't have any QKC tokens</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      oldAddress: '',
      newAddress: '',
      address: ''
    }
  },
  methods: {
    migrateToken() {
      if (!this.oldAddress || !this.newAddress) {
        this.status = 'Please fill in both addresses.'
        return
      }
      this.status = 'Migrating...'
      setTimeout(() => {
        this.status = 'Migration successful!'
      }, 1500)
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
  .convert-value {
    font-family: "Roboto Mono";
    font-weight: normal;
    margin-left: auto;
    text-align: right;
    color: rgb(23, 34, 162);
    font-size: 18px;
    line-height: 26px;
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
}
</style>
