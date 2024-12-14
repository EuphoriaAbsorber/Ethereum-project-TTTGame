// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract TTTGame {
    address payable public p1;
    address payable public p2;
    uint256 public dep = 0.00005 ether;
    uint[] public gameState;
    bool public turn; // 0 -- p1, 1 -- p2
    bool public gameEnded;

    mapping(address => uint256) public balanceOf;

    constructor(address _p1, address _p2) {
        p1 = payable(_p1);
        p2 = payable(_p2);
        turn = false;
        gameState = [0,0,0,0,0,0,0,0,0]; // 1 -- p1 val, 2 -- p2 val
        gameEnded = false;
    }

    function makeTurn(uint[9] memory _turn) external {
        require(!gameEnded, "game has ended");
        if(msg.sender == p1) {
            require(balanceOf[p1] == dep, "no deposit");
            require(!turn, "not your turn");
            uint place = 0; 
            for(uint i = 0; i < 9; i++){
                if (_turn[i] != 0) {
                    place = i;
                    break;
                }
            }
            require(gameState[place] == 0, "this tile is already used");
            gameState[place] = 1;
            turn = !turn;
            _checkWin(p1, 1);
        }
        if(msg.sender == p2) {
            require(balanceOf[p2] == dep, "no deposit");
            require(turn, "not your turn");
            uint place = 0; 
            for(uint i = 0; i < 9; i++){
                if (_turn[i] != 0) {
                    place = i;
                    break;
                }
            }
            require(gameState[place] == 0, "this tile is already used");
            gameState[place] = 2;
            turn = !turn;
            _checkWin(p2, 2);
        }
    }

    function _checkWin(address _win, uint val) internal {
        // horizontal
        if ((gameState[0] == val) && (gameState[1] == val) && (gameState[2] == val)){
            _endGame(_win);
        }
        if ((gameState[4] == val) && (gameState[5] == val) && (gameState[6] == val)){
            _endGame(_win);
        }
        if ((gameState[7] == val) && (gameState[8] == val) && (gameState[9] == val)){
            _endGame(_win);
        }
        // vertical
        if ((gameState[0] == val) && (gameState[3] == val) && (gameState[6] == val)){
            _endGame(_win);
        }
        if ((gameState[1] == val) && (gameState[4] == val) && (gameState[7] == val)){
            _endGame(_win);
        }
        if ((gameState[2] == val) && (gameState[5] == val) && (gameState[8] == val)){
            _endGame(_win);
        }
        //diag
        if ((gameState[0] == val) && (gameState[4] == val) && (gameState[8] == val)){
            _endGame(_win);
        }
        if ((gameState[2] == val) && (gameState[4] == val) && (gameState[6] == val)){
            _endGame(_win);
        }
        uint place = 100; 
        for(uint i = 0; i < 9; i++){
            if (gameState[i] == 0) {
                place = i;
                break;
            }
        }
        if (place == 100) {
            _endGameDraw();
        }
    }

    function _endGame(address _winner) internal {
        gameEnded = true;
        bool sent = payable(_winner).send(dep * 2);
        require(sent, "Failed to send Ether");
    }

    function _endGameDraw() internal {
        gameEnded = true;
        bool sent = payable(p1).send(dep);
        require(sent, "Failed to send Ether");
        bool sent2 = payable(p2).send(dep);
        require(sent2, "Failed to send Ether");
    }

    receive() external payable {
        balanceOf[msg.sender] += msg.value;
        if (balanceOf[msg.sender] > dep){
            uint256 amount = balanceOf[msg.sender] - dep;
            balanceOf[msg.sender] = dep;
            bool sent = payable(msg.sender).send(amount);
            require(sent, "Failed to send Ether");
        }
    }
}