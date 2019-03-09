App = {
  web3Provider: null,
  contracts: {},

  init: async function () {
    return await App.initWeb3();
  },

  initWeb3: async function () {
    // Modern dapp browsers...
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.enable();
      } catch (error) {
        // User denied account access...
        console.error("User denied account access")
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    }
    web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function () {
    $.getJSON('TicTacToe.json', function (data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var TicTacToeArtifact = data;
      App.contracts.TicTacToe = TruffleContract(TicTacToeArtifact);

      // Set the provider for our contract
      App.contracts.TicTacToe.setProvider(App.web3Provider);

      // Initialize the refresh loop
      App.initRefreshLoop()
    });
  },

  initRefreshLoop: function () {
    setInterval(function () {

      App.contracts.TicTacToe.deployed().then(function (instance) {

        // Retrieve the game Ids and populate the board list
        instance.getHostGamesIds().then(async function(ids){
          console.log(`ids : ${ids}`);

          var boardsDiv = document.getElementById("boards");
          boardsDiv.innerHTML = "";

          for(let id of ids){
            var boardDiv = document.createElement("div");
            var h1 = document.createElement("h1");
            h1.innerHTML = `Board ${id}`;
            
            var host = document.createElement("p");

            var hostId = await instance.getHostId(id);
            var hostBalance = await instance.getHostBalance(id);
            host.innerHTML = `Host player : ${hostId}  CashPrize : ${hostBalance}`;

            var opponent = document.createElement("p");

            var opponentId = await instance.getOpponentId(id);
            var opponentBalance = await instance.getOpponentBalance(id);
            opponent.innerHTML = `opponent player : ${opponentId}  CashPrize : ${opponentBalance}`;

            var playerTurn = document.createElement("p");
            var playerTurnId = await instance.getWhoCanPlay(id);

            var winner = await instance.getWhoWinGame(id);
            if(winner == hostId || winner == opponentId){
              playerTurn.innerHTML = 'Winner Player : ' + winner;
            }else if(playerTurnId == 0){
              playerTurn.innerHTML = 'It s your turn';
            }else{              
              playerTurn.innerHTML = 'It s turn of your opponent';
            }

            
            var table = document.createElement("table");

            for(i=0 ; i<3 ; i++){
              var tr = document.createElement("tr");
              tr.setAttribute("id", `row-${i}`);
              for(j=0 ; j<3 ; j++){
                var td = document.createElement("td");
                var btn = document.createElement("button");
                btn.innerHTML = "Play"
                if(playerTurnId == 0){
                  btn.setAttribute('onClick', "App.handlePlayGame("+ id + "," + i + "," + j +")");
                }
                td.setAttribute("id", `col-${j}`);
                var stateCell = await instance.getStateCell(id,i,j);
                //console.log("-- " + i + " " + j + "  " + stateCell)
                if(stateCell == 0){
                  td.appendChild(btn); 
                }else if(stateCell == 1){
                  td.innerHTML = "o"; 
                }else if (stateCell == 2){
                  td.innerHTML = "x";                   
                }else{
                  td.innerHTML = "bug"; 
                }

                tr.appendChild(td);
              }
              table.appendChild(tr);
            }

            boardDiv.appendChild(h1);
            boardDiv.appendChild(host);
            boardDiv.appendChild(opponent);
            boardDiv.appendChild(playerTurn);
            boardDiv.appendChild(table);
            boardsDiv.appendChild(boardDiv);
          }
        });

      });

    }, 1000);
  },

  handleInitGame: function () {

    var initGameValue = parseInt(document.getElementById("initGameValue").value);
    var opponentAddress = document.getElementById("initGameOpponent").value

    App.contracts.TicTacToe.deployed().then(
      (instance) => {
      instance.initGame(opponentAddress, initGameValue ).then(function () { });
    });
  },

  handleJoinGame: function () {
    //TODO L'opponent doit pouvoir faire joinGame en prenant les valeurs définies dans le html.
    var joinGameValue = document.getElementById("joinGameValue").value;
    var joinGameNumber = document.getElementById("joinGameNumber").value;
    App.contracts.TicTacToe.deployed().then(
      (instance) => {
      instance.joinGame(joinGameNumber, joinGameValue ).then(function () { });
    });
  },

  handlePlayGame: function (idGame, row, col){
    App.contracts.TicTacToe.deployed().then(
      (instance) => {
      instance.play(idGame, row, col ).then(function () { });
    });
  }

};

$(function () {
  $(window).load(function () {
    App.init();
  });
});
