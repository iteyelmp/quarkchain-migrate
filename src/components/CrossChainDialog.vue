<template>
	<el-dialog
			:visible.sync="visible"
			width="500px"
			:close-on-click-modal="false"
	>
		<div class="dialog-title">Cross-Chain Progress</div>
		<div class="step-column" v-for="(step, index) in steps" :key="index">
			<div class="step-row">
				<span class="step-label" :class="{'grey': step.status === 'pending'}">{{ step.label }}</span>

				<template v-if="step.status === 'pending'">
					<i class="el-icon-time step-icon grey"></i>
				</template>
				<template v-if="step.status === 'loading'">
					<i class="el-icon-loading step-icon loading"></i>
				</template>
				<template v-else-if="step.status === 'done'">
					<i class="el-icon-circle-check step-icon success"></i>
				</template>
				<template v-else-if="step.status === 'error'">
					<i class="el-icon-circle-close step-icon error"></i>
				</template>
			</div>

			<span class="tx-hash" v-if="step.hash">
					Tx Hash: <a class="tx-link" :href="explorerUrl(step.hash, step.chain)" target="_blank">{{ shortHash(step.hash) }}</a>
			</span>
		</div>
	</el-dialog>
</template>

<script>
export default {
	name: "CrossChainDialog",
	data() {
		return {
			visible: false,
			steps: [
				{ label: "L1 Tx Confirmed", status: "loading", hash: "", chain: "l1" },
				{ label: "L2 Tokens Minted", status: "pending", hash: "", chain: "l2" },
			],
		};
	},
	methods: {
		show() {
			this.visible = true;
		},
		updateStep(index, status, hash = "") {
			this.steps[index].status = status;
			this.steps[index].hash = hash;
		},
		explorerUrl(hash, chain) {
			if (chain === 'l1') {
				return `https://sepolia.etherscan.io/tx/${hash}`;
			} else if (chain === 'l2') {
				return `https://explorer.beta.testnet.l2.quarkchain.io/tx/${hash}`;
			}
			return '#';
		},
		shortHash(hash) {
			return hash.slice(0, 8) + "..." + hash.slice(-6);
		},
	},
};
</script>

<style scoped>
.dialog-title {
	font-size: 28px;
	color: rgb(23, 34, 162);
	margin: -15px 0 35px;
	font-weight: 500;
}
.step-column {
	display: flex;
	flex-direction: column;
	justify-content: flex-start;
	align-items: flex-start;
	margin-bottom: 25px;
}
.step-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
	width: 100%;
	padding: 0 12px;
}
.step-label {
	text-align: left;
	font-size: 16px;
	font-weight: 500;
	color: rgb(24, 30, 169);
	font-family: AktivGroteskEx;
}
.grey {
	color: grey;
}

.step-icon {
	width: 25px;
	height: 25px;
	border-radius: 50%;
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 14px;
	background-color: #f0f0f0;
}
.loading {
	color: rgb(23, 34, 162);
}
.success {
	color: #67c23a;
	background-color: #f0f9eb;
}

.error {
	color: #f56c6c;
	background-color: #fef0f0;
}

.tx-hash {
	padding: 0 12px 0 34px;
	margin-top: 4px;
	font-size: 13px;
	color: #606266;
	word-break: break-all;
}

.tx-link {
	margin-left: 8px;
	color: #409EFF;
	text-decoration: none;
}
.tx-link:hover {
	text-decoration: underline;
	background: none;
}
</style>

<style scoped>
/deep/ .el-dialog__headerbtn:hover .el-dialog__close {
	color: rgb(23, 34, 162) !important;
}

/deep/ .el-dialog {
	max-width: 90vw;
}
</style>

