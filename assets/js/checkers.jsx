import React from 'react';
import ReactDOM from 'react-dom';
import { Button } from 'reactstrap';
import classnames from 'classnames';

export default function init_checkers(root,channel) {
  ReactDOM.render(<Checkers channel={channel} />, root);
}

class Checkers extends React.Component {

  constructor(props) {
    super(props);
    this.channel = props.channel;
    this.state = {
       pawns: [],
       moves: {},
       first_player: null,
       second_player: null,
       chance: null,
       prevclick: null,
   };
   this.createBoard = this.createBoard.bind(this);
   this.channel.join()
        .receive("ok", this.renderView.bind(this))
        .receive("error",resp => {console.log("unable to join",resp)});
        this.channel.on("takeChance", payload => {this.setState(payload.game)})
        this.channel.on("joinTable", payload => {this.setState(payload.game)})
 }

 render(view){
   this.setState(view.game);
 }

  createBoard()
  {
    let pieces = [];
    for(let i=0;i<64;i++)
    {
      let tile = <Tile id={i}
                       key={i}
                       pawns={this.state.pawns}
                       prevclick={this.state.selectedTile}
                       player={this.state.lastturn}
                       tileSelected={this.tileSelected.bind(this)}
                       validMoves = {this.state.moves} takeChance={this.takeChance.bind(this)}/>;
      pieces.push(tile);
    }
    return pieces;
  }

  renderView(view){
     this.setState(view.game);
   }

  takeChance(id,pawn_id,color)
  {
  if((this.state.first_player == window.userName && this.state.turn == "red") ||
     (this.state.second_player == window.userName && this.state.turn == "black")){
      this.channel.push("takeChance", {id: id, pawn_id: pawn_id, color: color})
                .receive("ok", this.renderView.bind(this));
    }
  }

  displayTurn() {
      if (this.state.first_player == window.userName && this.state.turn == "red") {
      this.state.turn = "red"
      }
      if (this.state.second_player == window.userName && this.state.turn == "black") {
      this.state.turn ="black"
      }
  }

  tileSelected(id,pawn_id,color,player)
  {
    this.setState({selectedTile:pawn_id})
    this.setState({lastturn:color})
    let temp = this.state.moves
    if((this.state.first_player == window.userName && this.state.turn == "red" && color == "red") ||
       (this.state.second_player == window.userName && this.state.turn == "black"
        && color == "black")){
          this.channel.push("fetchTile", {id: pawn_id, color: color})
              .receive("ok", this.renderView.bind(this));
    }
 }

  hideButton() {
  var x = document.getElementById("join");
    if (x.style.display === "none") {
        x.style.display = "block";
    } else {
        x.style.display = "none";
    }
    this.channel.push("joinTable", {id: window.userName})
                .receive("ok", this.renderView.bind(this));
  }

  render()
  {
    if (this.state.pawns.length != 0){
      return(
      <div>
      <div id="join">
      <button className="primary-btn" onClick={()=>this.hideButton()}>
      Join the game
      </button></div>
    <div id="turn"><span class="text-light text-left">Player 1: {this.state.first_player}</span>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      Turn : {this.state.turn}
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
       <span class="text-light text-right">Player 2: {this.state.second_player}</span></div>
       <div id="layout">
          {this.createBoard()}
      </div>
      </div>
        );
      }
    else{
      return null;
    }
  }
}

function Tile(props) {
  const {id, pawns}= props;
  var c ='';
  if((parseInt(id / 8))%2==0) {
    if(id % 2 == 0) { c = "#ffffff"; }
    else { c = "#000000"; }
  } else { if(id % 2 == 0) { c = "#000000"; }
    else { c = "#ffffff"; }}
  var validTileMove = false;
  var openTile = true;
  let match = 'none'
  let initialTile = 99
  var com = false;
  for(let i=0;i<12;i++)
 {
        if(pawns.red[i].location === id) {
            match = 'red'
            initialTile  = pawns.red[i].id
        }
        else if (pawns.black[i].location === id){
            match = 'black'
            initialTile = pawns.black[i].id
        }
  }
  if(props.validMoves[id] !== undefined){
          com = true;
          validTileMove = true;
          openTile = false;
  }
  var m = classnames(
               'empty':true,
              {'red piece king': (match === 'red') && (pawns.red[initialTile].king) === true},
              {'black piece king': (match === 'black') && (pawns.black[initialTile].king) === true},
              {'red piece': (match === 'red') && (pawns.red[initialTile].king === false)},
              {'black piece': (match === 'black') && (pawns.black[initialTile].king === false)},
              );
  var p = classnames(
          {'block': openTile},
          {'validblock': validTileMove}
  );
  return (
          <div className= {p} style={{backgroundColor: c}}
            onClick={com ? () => props.takeChance(id, props.prevclick, props.player) : null}>
          <div className ={m} onClick={() => props.tileSelected(id, initialTile, match, props.player)}/>
          </div>
  );
}
