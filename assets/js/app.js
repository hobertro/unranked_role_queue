// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import { Socket } from "phoenix"
import React from 'react';
import ReactDOM from 'react-dom';

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"


const roles   = ["Undecided", "Carry", "Mid", "Offlane", "Offlane Support", "Hard Support"]
const role_list   = roles.map((role, index) => {
  return {
    name: role,
    position: index,
    reserved: false 
  }
})

class Game extends React.Component {
  constructor(props){
    super(props);
    this.state = {
      players: [],
      roles: role_list,
      input: "",
      current_player: {role: "Undefined"}
    }
    
    this.assignPlayerRole   = this.assignPlayerRole.bind(this);
    this.assignRole   = this.assignRole.bind(this);
    this.updateRoles  = this.updateRoles.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  componentDidMount(){
    const { gameName, authToken, userTag } = document.getElementById('root').dataset
    this.setState({
      game_name: gameName,
      user_tag: userTag
    })
    this.joinChannel(gameName, authToken, userTag)
  }

  findCurrentPlayer(players, userTag){
    return players.filter((player) => {
      return player.id === userTag;
    })
  }

  joinChannel(gameName, authToken, userTag){
    const socket = new Socket("/socket", { params: { token: authToken } })
    socket.connect()
    this.channel = socket.channel(`games:${gameName}`, {userTag: userTag})
        
    this.channel.on("game_summary", summary => {
        console.log('game summary', summary)

        this.setState({
          roles: [...summary["roles"]],
          players: [...summary["players"]],
          current_player: this.findCurrentPlayer(summary["players"], userTag)[0]
        });
      }
    )

    this.channel.on("assign_role", summary => { 
      this.setState({
        roles: [...summary["roles"]],
        players: [...summary["players"]],
        current_player: this.findCurrentPlayer(summary["players"], userTag)[0]
      });
        console.log('assign role', summary)
      }
    )
      

    this.channel.join()
      .receive("ok", response => {
        console.log(`Joined ${gameName} 😊`)
      })
      .receive("error", response => {
        this.error = `Joining ${gameName} failed 🙁`
        console.log(this.error, response)
      })
  }

  updateRoles(roles) {
    this.setState({
      roles: roles
    })
  }

  assignRole(role_name, index){
    let player = this.state.players[index]
    let selected_role = this.findRole(role_name.target.value)[0]
    let current_role  = this.findRole(player.role)[0]

    selected_role.reserved = true
    if (!(current_role === "Undecided")){
      current_role.reserved  = false
    }
    player.role = selected_role.name
    this.channel.push("assign_role", {user_tag: this.state.user_tag, game_name: this.state.game_name, role: selected_role.name})
    this.setState({
      roles: [...this.state.roles],
      players: [...this.state.players]
    });
  }

  assignPlayerRole(role_name, current_player){
    let player = current_player

    let selected_role = this.findRole(role_name.target.value)[0]
    let current_role  = this.findRole(current_player.role)[0]

    selected_role.reserved = true
    if (!(current_role === "Undecided")){
      current_role.reserved  = false
    }
    player.role = selected_role.name
    this.channel.push("assign_role", {user_tag: this.state.user_tag, game_name: this.state.game_name, role: selected_role.name})
  }

  findRole(role_name){
    if (role_name === "Undecided"){
      return ["Undecided"]
    }
    return this.state.roles.filter((role) => {
      return role.name === role_name;
    })
  }

  refreshRoles(){
    this.state.players.forEach((player) => {
      player.role = "Undecided"
    })
    this.state.roles.forEach((role) => {
      role.reserved = false
    })
    this.setState({
      players: [...this.state.players],
      roles: [...this.state.roles]
    })
  }

  assignRandomRoles(){
    let players = this.state.players
    let roles   = this.state.roles
    players.forEach(function(player){
      let index = Math.floor(Math.random() * (roles.length));
      let role  = roles[index];
      if (role.reserved === true){
        return;
      }
      player.role = role.name;
      role.reserved = true
    })
    this.setState({
      players: [...players],
      roles: [...roles]
    })
  }
  
  randomNumber(arr){
    let number = Math.floor(Math.random() * (arr.length));
    return number;
  }
  
  removeRole(player){
    this.state.roles.push(player.role)
    player.role = null;
    return player;
  }

  handleChange(e) {
    this.setState({ input: e.target.value });
  }
  
  handleSubmit(e) {
    e.preventDefault();
    if (this.state.input.length === 0) {
      return;
    }
    if (this.state.players.length > 4) {
      alert("You can only add a maximum of 5 players");
      return;
    }
    const newPlayer = this.createPlayer(this.state.input)
    this.setState({
      players: [...this.state.players, newPlayer],
      input: ''
    })
  }

  render() {
    return (
      <div className="main">
        <div className="roles">
          <h1>Select a Role:</h1>
          <RoleSelector currentPlayer={this.state.current_player} roles={this.state.roles} assignPlayerRole={this.assignPlayerRole}/>
          <button onClick={() => this.refreshRoles()} className="refreshRoles">
            Refresh Roles
          </button>
        </div>
        <div className="current_player">
          <h1>Your current role is: {this.state.current_player.role}</h1>
        </div>
        <div className="players">
          <h1>Players</h1>
          <PlayerList user_tag={this.state.user_tag} players={this.state.players} roles={this.state.roles} updateRoles={this.updateRoles} assignRole={this.assignRole} />
        </div>

        <div className="assignRandomRole">
          <h1>Assign Random roles</h1>
          <div className="assignRoles">
            <button onClick={() => this.assignRandomRoles()} className="assignRolesButton">
              Assign Roles
            </button>
          </div>
        </div>
      </div>
    );
  }
}

class PlayerList extends React.Component {
  render(){
    return <ul className="player_list">
      {
        this.props.players.map((player, index) => (
          <Player user_tag={this.props.user_tag} key={player.id} player_id={player.id} name={player.name} role={player.role} roles={this.props.roles} updateRoles={this.props.updateRoles} assignRole={this.props.assignRole} index={index}/>
        ))
      }
    </ul>
  }
}

class Player extends React.Component {
  render(){
    return (
      <li className="player" key={this.props.id}>{this.props.name} 
        <select disabled={this.props.player_id !== this.props.user_tag } name="roles" value={this.props.role} onChange={(e) => {this.props.assignRole(e, this.props.index)}}>
          {
            this.props.roles.map(role => (
              <option key={role.name} value={role.name} disabled={!(role.name === "Undecided") && role.reserved}>{role.name}</option>
            ))
          }
        </select>
        Role: {this.props.role}
      </li>)
  }
}

class RoleSelector extends React.Component {  
  render(){
    return <RoleList roles={this.props.roles} currentPlayer={this.props.currentPlayer} assignPlayerRole={this.props.assignPlayerRole} />
  }
}

class RoleList extends React.Component { 
  renderRole(role) {
    return <Role name={role.name} key={role.name} currentPlayer={this.props.currentPlayer} assignPlayerRole={this.props.assignPlayerRole} />;
  }

  render() {
    return (
      <ul className="role_list">
        {
          this.props.roles.map(role => this.renderRole(role))
        }
      </ul>
    )
  }
}

class Role extends React.Component {
  render() {
    return (
      <li className="role_wrap">
        <button value={this.props.name} className="role" onClick={(e) => { this.props.assignPlayerRole(e, this.props.currentPlayer)} }>
          { this.props.name }
        </button>
      </li>
    )
  }
}

ReactDOM.render(
  <Game />,
  document.getElementById('root')
);