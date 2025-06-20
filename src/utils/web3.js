import { ethers } from "ethers";

const ERC20_ABI = [
    "function balanceOf(address owner) view returns (uint256)",
    "function allowance(address owner, address spender) view returns (uint256)",
    "function approve(address spender, uint256 amount) returns (bool)"
];

const CONVERT_ABI = [
    "function convert() external",
];

const MAX_UINT = "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";

export async function getErc20Balance(tokenAddress, userAddress) {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const contract = new ethers.Contract(tokenAddress, ERC20_ABI, provider);
    return await contract.balanceOf(userAddress);
}

export async function getErc20Allowance(tokenAddress, userAddress, convertAddress) {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const contract = new ethers.Contract(tokenAddress, ERC20_ABI, provider);
    return await contract.allowance(userAddress, convertAddress);
}

export async function getL2QKCBalance(rpc, userAddress) {
    const provider = new ethers.JsonRpcProvider(rpc);
    return await provider.getBalance(userAddress);
}

export async function approveErc20(tokenAddress, convertAddress) {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    const contract = new ethers.Contract(tokenAddress, ERC20_ABI, signer);
    const tx = await contract.approve(convertAddress, MAX_UINT);
    return await tx.wait();
}

export async function convert(convertAddress) {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const signer = await provider.getSigner();
    const contract = new ethers.Contract(convertAddress, CONVERT_ABI, signer);
    const tx = await contract.convert();
    await tx.wait();
}
