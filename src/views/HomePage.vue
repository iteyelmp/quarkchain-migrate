<template>
	<div class="home-container">
		<p class="home-title">QuarkChain Token Migration</p>
		<div class="home-message">
			To seamlessly integrate QuarkChain with Ethereum’s rollup infrastructure, the original ERC-20 QKC token (L1)
			needs to be migrated to a new ERC-20 QKC token (L2) at a 1:1 ratio.
		</div>

		<div class="home-convert">
			<div class="row-layout">
				<p class="convert-title">Migrate Amount:</p>

				<el-input
						v-model="input"
						type="number"
						placeholder="Enter amount"
						class="convert-input"
				>
					<template #append>QKC</template>
				</el-input>

				<el-button
						class="convert-button"
						@click="clickButton"
						:disabled="isButtonDisabled">
					Start
				</el-button>
			</div>
			<p class="convert-note">
				⚠️ Note: This is a one-way migration. Once your QKC is migrated, it cannot be transferred back.
			</p>
		</div>

		<p class="show-more">My Balance</p>
		<div class="convert-detail">
			<div class="row-layout">
				<p class="detail-title">QKC (L1):</p>
				<div class="detail-value convert-value-old">{{ oldBalStr }} QKC</div>
			</div>
			<div class="row-layout detail-margin">
				<p class="detail-title">QKC (L2):</p>
				<div class="detail-value convert-value-new">{{ newBalStr }} QKC</div>
			</div>
			<div class="row-layout detail-margin">
				<p class="detail-title">Address:</p>
				<div class="convert-value convert-value-address">{{ accountStr }}</div>
			</div>
		</div>

		<cross-chain-dialog ref="progressDialog" @finish="onFinish"/>
	</div>
</template>

<script>
import {ethers} from 'ethers';
import {getErc20Balance, getL2QKCBalance} from "@/utils/web3";
import CrossChainDialog from "@/components/CrossChainDialog.vue";

export default {
	data() {
		return {
			oldBalance: 0n,
			newBalance: 0n,
			isFetching: false,

			input: '',
		}
	},
	components: {
		CrossChainDialog
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
			try {
				if (!this.input || isNaN(this.input)) return true;

				const inputWei = ethers.parseUnits(this.input.toString(), 18);
				return (
						!this.account ||
						this.oldBalance <= 0n ||
						inputWei > this.oldBalance
				);
			} catch (e) {
				return true;
			}
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
				const [oldToken, newToken] = await Promise.all([
					getErc20Balance(this.OldToken, this.account),
					getL2QKCBalance(this.L2Rpc, this.account)
				]);
				this.oldBalance = oldToken;
				this.newBalance = newToken;
			} finally {
				this.isFetching = false;
			}
		},
		async clickButton() {
			this.$refs.progressDialog.show({
				amount: this.input,
				balance: this.oldBalance,
				account: this.account,
				conversion: this.Conversion,
				oldToken: this.OldToken,
				l2Rpc: this.L2Rpc
			});
		},
		onFinish() {
			this.fetchBalances();
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
	margin: 35px auto;
	padding: 25px;
}

.home-title {
	position: relative;
	font-family: AktivGroteskEx;
	font-weight: 300;
	font-size: 14px;
	line-height: 15px;
	letter-spacing: 2px;
	color: #1722a2;
	text-transform: uppercase;
	padding-left: 150px;
	margin-bottom: 30px;
	display: flex;
	-webkit-box-align: center;
	align-items: center;
}

.home-title::before {
	content: "";
	position: absolute;
	top: 6px;
	left: 0px;
	width: 142px;
	height: 1px;
	background: rgb(23, 34, 162);
}

.home-message {
	font-style: normal;
	font-weight: 400;
	font-size: 14px;
	line-height: 19px;
	color: #181ea9;
	opacity: 0.8;
	margin-bottom: 3px;
	text-align: left;
}

.home-convert {
	margin-top: 45px;
	padding: 25px 30px;
	border: 1px solid rgba(24, 30, 169, 0.3);

	.row-layout {
		display: flex;
		flex-direction: row;
		justify-content: space-between;
		align-items: center;
		gap: 25px;
	}

	.convert-title {
		font-family: AktivGroteskEx;
		font-weight: bold;
		color: rgb(23, 34, 162);
		font-size: 14px;
		line-height: 14px;
	}

	.convert-input {
		flex: 1;
	}
	.convert-input ::v-deep .el-input__inner {
		color: rgb(24, 30, 169);
		font-size: 14px;
		line-height: 14px;
		border-color: rgba(24, 30, 169, 0.3);
	}
	.convert-input ::v-deep .el-input-group__append {
		background-color: transparent;
		color: rgb(24, 30, 169);
		font-weight: 500;
		border-color: rgba(24, 30, 169, 0.3);
	}


	.convert-button {
		cursor: pointer;
		width: 20%;
		background: rgb(24, 30, 169);
		border: none;
		font-size: 14px;
		line-height: 14px;
		color: rgb(255, 255, 255);
		border-radius: 4px;
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

	.convert-note {
		font-style: normal;
		font-size: 12px;
		line-height: 1.5;
		color: red;
		width: 85%;
		margin: 15px auto 0;
	}
}


.show-more {
	font-weight: 500;
	font-size: 18px;
	color: rgb(24, 30, 169);
	text-align: left;
	margin: 38px 0 15px;
}

.convert-detail {
	border: 1px solid rgba(24, 30, 169, 0.3);
	padding: 25px 30px;

	.row-layout {
		display: flex;
		flex-direction: row;
		justify-content: space-between;
		align-items: center;
		gap: 25px;
	}

	.detail-margin {
		margin-top: 15px;
	}

	.detail-title {
		font-style: normal;
		line-height: 18px;
		color: rgb(24, 30, 169);
		font-size: 13px;
		font-weight: 500;
		opacity: 0.8;
	}

	.detail-value {
		font-style: normal;
		line-height: 18px;
		font-size: 13px;
		font-weight: 400;
	}

	.convert-value-old {
		color: #F4A261;
	}

	.convert-value-new {
		color: #3B4BFF;
	}

	.convert-value-address {
		color: #666;
		font-family: "Roboto Mono", monospace;
	}
}

.fade-enter-active, .fade-leave-active {
	transition: opacity 0.3s ease;
}

.fade-enter, .fade-leave-to {
	opacity: 0;
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
