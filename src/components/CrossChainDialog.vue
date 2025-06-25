<template>
	<el-dialog
			title="Cross-Chain Progress"
			:visible.sync="visible"
			width="500px"
			:close-on-click-modal="false"
	>
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
					Tx Hash: <a class="tx-link" :href="explorerUrl(step.hash)" target="_blank">{{ shortHash(step.hash) }} </a>
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
				{ label: "L1 Tx Confirmed", status: "loading", hash: "" },
				{ label: "L2 Tokens Minted", status: "pending", hash: "" },
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
		explorerUrl(hash) {
			// TODO
			return `https://your-block-explorer/tx/${hash}`;
		},
		shortHash(hash) {
			return hash.slice(0, 8) + "..." + hash.slice(-6);
		},
	},
};
</script>

<style scoped>
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
	padding: 0 10px;
}
.step-label {
	font-weight: 400;
	text-align: left;
	font-size: 16px;
	color: rgb(24, 30, 169);
	font-family: AktivGroteskEx;
}
.grey {
	color: grey;
}
.step-icon {
	font-size: 18px;
	margin-right: 8px;
}
.loading {
	color: rgb(23, 34, 162)
}
.success {
	color: #67c23a;
}
.error {
	color: #f56c6c;
}

.tx-hash {
	padding: 0 10px 0 30px;
	margin-top: 5px;
	font-size: 12px;
}
.tx-link {
	margin-left: 8px;
	color: #409EFF;
}
</style>

<style scoped>
/deep/ .el-dialog__headerbtn:hover .el-dialog__close {
	color: rgb(23, 34, 162) !important;
}
</style>
