<template>
	<el-dialog
			:visible.sync="visible"
			:show-close="false"
			custom-class="responsive-dialog"
	>
		<div class="dialog-header">
			<div class="dialog-title">Migrate {{ this.amount }} QKC</div>
			<i class="el-icon-close close-icon close-btn" @click="visible = false"></i>
		</div>

		<div class="step-column">
			<div class="step-row" :class="{ success: steps > 1 }">
				<div class="step-label-layout">
					<img class="step-icon" src="@/assets/l1.svg"/>
					<span class="step-label">Step 1: Approve QKC</span>
				</div>
				<el-button
						class="convert-button"
						@click="clickApprove"
						:loading="loading === 1"
						:disabled="steps !== 1">
					Approve
				</el-button>
			</div>

			<div class="step-row" :class="{ success: steps > 2 }">
				<div class="step-label-layout">
					<img class="step-icon" src="@/assets/l1.svg"/>
					<span class="step-label">Step 2: Submit Migration (L1)</span>
				</div>
				<el-button
						class="convert-button"
						@click="clickMigration"
						:loading="loading === 2"
						:disabled="steps !== 2">
					Migration
				</el-button>
			</div>

			<div class="step-row" :class="{ success: steps === 3 && isFinish}">
				<div class="step-label-layout">
					<img class="step-icon" src="@/assets/logo.png"/>
					<span class="step-label">Step 3: Wait ~3 mins for L2 confirmation</span>
				</div>

				<i v-if="steps === 3 && !isFinish" class="el-icon-loading wait-loading"></i>
				<font-awesome-icon v-else-if="isFinish" icon="check-circle" class="wait-finish" />
				<div v-else></div>
			</div>
		</div>
	</el-dialog>
</template>

<script>
import {approveErc20, convert, getErc20Allowance, waitForL2Mint} from "@/utils/web3";
import {ethers} from "ethers";

export default {
	name: "CrossChainDialog",
	data() {
		return {
			visible: false,
			steps: 1,
			isFinish: false,
			loading: 0,

			amount: 0n,
			balance: 0n,
			account: null,
			oldToken: null,
			conversion: null,
			l2Rpc: null,
		};
	},
	methods: {
		formatAmount(amount) {
			return ethers.parseEther(amount.toString());
		},
		show({amount, balance, account, conversion, oldToken, l2Rpc}) {
			this.amount = amount;
			this.balance = balance;
			this.account = account;
			this.conversion = conversion;
			this.oldToken = oldToken;
			this.l2Rpc = l2Rpc;

			this.visible = true;
			this.loadData();
		},
		async loadData() {
			const allowance = await getErc20Allowance(this.oldToken, this.account, this.conversion);
			if (allowance >= this.formatAmount(this.amount)) this.steps = 2;
		},
		async clickApprove() {
			this.loading = 1;
			try {
				await approveErc20(this.oldToken, this.conversion);
				const allowance = await getErc20Allowance(this.oldToken, this.account, this.conversion);
				if (allowance >= this.formatAmount(this.amount)) {
					this.steps = 2;
					this.$message.success("Approved successfully.");
				} else {
					this.$message.error("Approved amount < migration amount.");
				}
			} catch (e) {
				this.$message.error("Approve failed.");
			}
			this.loading = 0;
		},
		async clickMigration() {
			this.loading = 2;
			try {
				await convert(this.conversion, this.amount);
				this.steps = 3;
				this.$message.success("Migration submitted.");
				this.l2Mint();
			} catch (e) {
				this.$message.error("Migration failed.");
			}
			this.loading = 0;
		},
		async l2Mint() {
			try {
				await waitForL2Mint(this.l2Rpc, this.account);
				this.$emit('finish')
				this.isFinish = true;
				this.$message.success("L2 mint completed.");
			} catch (e) {
				this.$message.error("L2 mint timeout.");
			}
		},
	},
};
</script>

<style scoped lang="scss">
.dialog-header {
	margin-top: -40px;
	display: flex;
	flex-direction: row;
	justify-content: space-between;
	align-items: flex-start;

	.dialog-title {
		font-size: 24px;
		color: rgb(23, 34, 162);
		font-weight: 500;
		text-align: left;
		font-family: CoinbaseSansBlob;
	}

	.close-btn {
		font-size: 18px;
		cursor: pointer;
		width: 30px;
		height: 30px;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		background-color: #f0f0f0;
	}
	.close-btn:hover {
		color: rgb(23, 34, 162);
		opacity: 0.8;
	}
}

.step-column {
	display: flex;
	flex-direction: column;
	justify-content: center;
	align-items: center;
	margin-top: 30px;
	gap: 15px;
}

.step-row {
	display: flex;
	flex-direction: row;
	justify-content: space-between;
	align-items: center;
	width: 100%;
	background-color: #f4f4f5;
	border-radius: 8px;
	padding: 8px 12px;
	backdrop-filter: blur(6px);
	-webkit-backdrop-filter: blur(6px);
}
.success {
	background: rgba(103, 194, 58, 0.1);
	border-radius: 8px;
}

.step-label-layout {
	display: flex;
	flex-direction: row;
	justify-content: left;
	align-items: center;

	.step-icon {
		width: 2rem;
		height: 2rem;
		border-radius: 10px;
	}
	.step-label {
		text-align: left;
		font-size: 14px;
		font-weight: 500;
		color: rgb(24, 30, 169);
		margin-left: 8px;
		font-family: CoinbaseDisplay;
	}
}


.convert-button {
	cursor: pointer;
	width: 25%;
	background: rgb(24, 30, 169);
	border: none;
	font-size: 13px;
	line-height: 13px;
	color: rgb(255, 255, 255);
	border-radius: 4px;
	font-family: CoinbaseSansBlob;
}
.convert-button:enabled:hover {
	background: rgba(24, 30, 169, 0.7);
	color: rgb(255, 255, 255);
	border: 0;
}
.convert-button:disabled {
	background: rgba(24, 30, 169, 0.4) !important;
	color: rgba(255, 255, 255, 0.8) !important;
	cursor: not-allowed;
}

.wait-loading {
	font-size: 20px;
	margin-right: 10px;
	color: rgb(23, 34, 162);
}
.wait-finish {
	font-size: 20px;
	margin-right: 10px;
	color: #67c23a;
	animation: fadeIn 0.4s ease-in;
}
@keyframes fadeIn {
	from {
		opacity: 0;
		transform: scale(0.8);
	}
	to {
		opacity: 1;
		transform: scale(1);
	}
}


@media screen and (max-width: 500px) {
	.dialog-header {
		margin-top: -40px;

		.dialog-title {
			font-size: 16px;
		}

		.close-btn {
			font-size: 16px;
			width: 24px;
			height: 24px;
		}
	}

	.step-column {
		margin-top: 25px;
		gap: 15px;
	}

	.step-label-layout {

		.step-icon {
			width: 1.8rem;
			height: 1.8rem;
			border-radius: 10px;
		}
		.step-label {
			font-size: 13px;
		}
	}


	.convert-button {
		width: 25%;
		font-size: 12px;
		line-height: 12px;
		padding-left: 0;
		padding-right: 0;
	}

	.wait-loading {
		font-size: 18px;
	}
	.wait-finish {
		font-size: 18px;
	}
}
</style>


<style>
.el-dialog.responsive-dialog {
	max-width: 500px;
}

/deep/ .el-dialog {
	border-radius: 8px;
}

@media screen and (max-width: 500px) {
	.el-dialog.responsive-dialog {
		width: 95% !important;
	}
}
</style>

