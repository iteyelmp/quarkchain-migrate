<template>
  <div class="footer-div">
    <div class="footer-b">
      <div class="footer-b-text">BUILT BY QUARKCHAIN WITH ❤️️</div>
      <div class="foot-img">
        <span v-if="this.Conversion" class="foot-link" @click="goEtherscan">Contract</span>
        <span class="foot-link" @click="goTwitter">Twitter</span>
        <span class="foot-link" @click="goDiscord">Discord</span>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "FooterPage",
  computed: {
    Conversion() {
      return this.$store.state.chainConfig?.Conversion || null;
    },
  },
  methods: {
    goTwitter(){
      window.open('https://x.com/quark_chain', "_blank");
    },
    goDiscord(){
      window.open('https://discord.com/invite/GbkGhY3qkh', "_blank");
    },
    goEtherscan() {
      if (!this.Conversion) {
        return;
      }
      window.open('https://sepolia.etherscan.io/address/' + this.Conversion + '#code', "_blank");
    }
  }
};
</script>

<style scoped lang="scss">
.footer-div {
  position: relative;
  width: 100%;
  height: 82px;
}

.footer-b {
  max-width: 1200px;
  margin: 20px auto;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;

  .footer-b-text {
    color: #000;
    font-size: 10px;
    font-style: normal;
    font-weight: 700;
    line-height: normal;
    text-transform: uppercase;
    font-feature-settings: 'liga' off, 'clig' off;
    font-family: CoinbaseDisplay;
  }

  .foot-img {
    display: flex;
    flex-direction: row;
    justify-content: center;
    align-items: center;

    .foot-link {
      cursor: pointer;
      color: #1722A2;
      font-size: 14px;
      font-weight: 600;
      margin-right: 18px;
      text-decoration: underline;
      transition: color 0.2s;

      &:hover {
        color: #648BFD;
      }
    }
  }
}

@media screen and (max-width: 500px) {
  .footer-div {
    height: auto;
  }

  .footer-b {
    padding: 0 0 30px;
    width: 92%;
    margin: 48px auto 0;

    .footer-b-text {
      font-size: 10px;
    }

    .foot-img {
      .foot-link {
        font-size: 11px;
        margin-right: 10px;
      }
    }
  }
}
</style>
