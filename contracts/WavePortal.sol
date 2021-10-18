pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {

    uint256 totalWaves;
    address mostWaves;
    Wave[] waves;
    mapping(address => uint256) public userWaves;
    mapping(address => uint256) public lastWavedAt;
    uint private seed;

    /*
     * A little magic, Google what events are in Solodity!
     */
    event NewWave(address indexed from, uint256 timestamp, string message);

    /*
     * I created a struct here named Wave.
     * A struct is basically a custom datatype where we can customize what we want to hold inside it.
     */
    struct Wave {
        address waver; // The address of the user who waved.
        string message; // The message the user sent.
        uint256 timestamp; // The timestamp when the user waved.
    }


    constructor() payable {
        console.log("Yo yo, I am a contract and I am smart");
    }

    function wave(string memory _message) public {
        /*
         * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
         */
        require(
            lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
            "Wait 15m"
        );
        //update current timestamp
        lastWavedAt[msg.sender] = block.timestamp;
        totalWaves += 1;
        console.log("%s has waved", msg.sender);
        userWaves[msg.sender] ++;


         /*
         * This is where I actually store the wave data in the array.
         */
        waves.push(Wave(msg.sender, _message, block.timestamp));
        /*
         * Generate a Psuedo random number between 0 and 100
         */
        uint256 randomNumber = (block.difficulty + block.timestamp + seed) % 100;
        console.log("Random # generated: %s", randomNumber);

        /*
         * Set the generated, random number as the seed for the next wave
         */
        seed = randomNumber;
        
          /*
         * Give a 50% chance that the user wins the prize.
         */
        if (randomNumber < 50) {
            console.log("%s won!", msg.sender);

            /*
             * The same code we had before to send the prize.
             */
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }


    /*
     * I added a function getAllWaves which will return the struct array, waves, to us.
     * This will make it easy to retrieve the waves from our website!
     */
    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }

    function getUserWaves() public view returns (uint256) {
        console.log("We have %d user waves!", userWaves[msg.sender]);
        return userWaves[msg.sender];
    }
}