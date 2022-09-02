%lang starknet
from starkware.cairo.common.uint256 import Uint256, uint256_sub, uint256_add, uint256_eq


@contract_interface
namespace IcPool:
    func get_token_balance() -> (bal : Uint256):
    end

    func get_c_token_balance() -> (bal : Uint256):
    end
end



# interface RocketNetworkBalancesInterface {
#     function getBalancesBlock() external view returns (uint256);
#     function getLatestReportableBlock() external view returns (uint256);
#     function getTotalETHBalance() external view returns (uint256);
#     function getStakingETHBalance() external view returns (uint256);
#     function getTotalRETHSupply() external view returns (uint256);
#     function getETHUtilizationRate() external view returns (uint256);
#     function submitBalances(uint256 _block, uint256 _total, uint256 _staking, uint256 _rethSupply) external;
#     function executeUpdateBalances(uint256 _block, uint256 _totalEth, uint256 _stakingEth, uint256 _rethSupply) external;
# }