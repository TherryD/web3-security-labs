// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Fallback (Desafio Ethernaut #01)
 * @notice Contrato vulnerável a tomada de controle administrativo (Privilege Escalation).
 * @dev A função receive() permite alterar o `owner` sem exigir que as contribuições superem o dono atual.
 */
contract Fallback {
    mapping(address => uint256) public contributions;
    address public owner;

    constructor() {
        owner = msg.sender;
        // Define uma barreira alta (1000 ETH) para assumir a posse via contribute()
        contributions[msg.sender] = 1000 * (1 ether);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    /// @notice Permite pequenas contribuições (< 0.001 ETH) para tentar superar o saldo do owner
    function contribute() public payable {
        require(msg.value < 0.001 ether);
        contributions[msg.sender] += msg.value;
        if (contributions[msg.sender] > contributions[owner]) {
            owner = msg.sender;
        }
    }

    function getContribution() public view returns (uint256) {
        return contributions[msg.sender];
    }

    /// @notice Permite apenas ao dono atual sacar todo o saldo do contrato
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    /**
     * @notice VULNERABILIDADE: Executada ao receber ETH direto sem dados (calldata vazio).
     * @dev Exige apenas que o remetente já tenha contribuído qualquer valor (> 0) anteriormente,
     *      contornando completamente a regra de negócio da função contribute().
     */
    receive() external payable {
        require(msg.value > 0 && contributions[msg.sender] > 0);
        owner = msg.sender;
    }
}