import { ethers } from "ethers";

const ERC20_ABI = [
    "function balanceOf(address owner) view returns (uint256)",
];

export async function getErc20Balance(tokenAddress, userAddress) {
    const provider = new ethers.BrowserProvider(window.ethereum);
    const contract = new ethers.Contract(tokenAddress, ERC20_ABI, provider);
    return await contract.balanceOf(userAddress);
}
