<template>
  <div class="footer-div">
    <div class="footer-bg"/>
    <div class="footer-top" data-aos="fade-up">
      <div class="subscribe-title">Join us in powering the future with the Super World Computer.</div>
      <el-button class="sub-button" @click="goTelegram">
        Join Us
      </el-button>
    </div>
    <div class="footer-b">
      <div class="footer-b-text">BUILT BY QUARKCHAIN WITH ❤️️</div>
      <div  class="foot-img">
        <img class="footer-b-img" src="@/assets/discord.svg" @click="goDiscord"/>
        <img class="footer-b-img2" src="@/assets/twitter.svg" @click="goTwitter"/>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "FooterPage",
  methods: {
    goTwitter(){
      window.open('https://x.com/quark_chain', "_blank");
    },
    goDiscord(){
      window.open('https://discord.com/invite/GbkGhY3qkh', "_blank");
    },
    goTelegram(){
      window.open('https://t.me/quarkchainio', "_blank");
    },
  }
};
</script>

<style scoped lang="scss">
.footer-div {
  position: relative;
  width: 100%;
  height: 300px;
  background: #FAFCFF;
  overflow: hidden;
}

.footer-bg {
  position: absolute;
  left: 50%;
  top: 100%;
  transform: translate(-50%, -40%);
  width: 2607px;
  height: 1299px;
  border-radius: 2607px;
  opacity: 0.7;
  background: radial-gradient(42.16% 42.16% at 50.02% 56.61%, #C8D6FF 0%, rgba(250, 250, 255, 0.00) 100%);
}

.footer-top {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;

  .subscribe-title {
    color: #090909;
    font-size: 32px;
    font-style: normal;
    font-weight: 400;
    line-height: 116%;
    font-feature-settings: 'liga' off, 'clig' off;
    font-family: CoinbaseDisplay;
  }

  .sub-button {
    margin-top: 28px;
    padding: 16px;
    width: 199px;
    border-radius: 12px;
    background: #648BFD;
    box-shadow: -2px 1px 4px 0px rgba(129, 129, 147, 0.15);

    color: #FFF;
    font-size: 16px;
    font-style: normal;
    font-weight: 500;
    line-height: 116%;
    font-feature-settings: 'liga' off, 'clig' off;
    font-family: CoinbaseDisplay;
  }
  .sub-button:focus,
  .sub-button:hover {
    color: #FFFFFF;
    background: #7EACFC;
  }
}


.footer-b {
  padding: 0 25px 42px;
  max-width: 1200px;
  margin: 110px auto;
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
    .footer-b-img {
      cursor: pointer;
      width: 42px;
      height: 42px;
      margin-right: 18px
    }
    .footer-b-img2 {
      cursor: pointer;
      width: 36.79px;
      height: 32.702px;
    }
  }
}

@media screen and (max-width: 500px) {
  .footer-div {
    height: auto;
  }

  .footer-bg {
    position: absolute;
    left: 50%;
    top: 100%;
    transform: translate(-50%, -40%);
    width: 2607px;
    height: 1299px;
    border-radius: 2607px;
    opacity: 0.75;
    background: radial-gradient(42.16% 42.16% at 50.02% 56.61%, #BFC1F5 0%, rgba(250, 250, 255, 0.00) 100%);
  }

  .footer-top {
    width: 90%;

    .subscribe-title {
      margin-top: 60px;
      font-size: 24px;
    }

    .sub-button {
      margin-top: 48px;
      width: 140px;
    }
  }


  .footer-b {
    padding: 0 0 42px;
    width: 90%;
    margin: 48px auto 0;

    .footer-b-text {
      font-size: 10px;
    }
    .footer-b-img2 {
      width: 36px;
      height: 36px;
    }
    .footer-b-img2 {
      width: 34px;
      height: 30px;
    }
  }
}
</style>
