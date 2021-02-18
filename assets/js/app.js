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
      current_player: {role: "Undefined"},
      heroes: []
    }
    
    this.assignRole   = this.assignRole.bind(this);
    this.assignHero   = this.assignHero.bind(this);
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
          heroes: [...summary["heroes"]],
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

    this.channel.on("assign_hero", summary => { 
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

  assignHero(hero_name, current_player){
console.log(hero_name, "hero_name");
console.log(current_player, "current_player");
    // let player = current_player

    // let selected_role = this.findHero(role_name)[0]
    // let current_role  = this.findHero(current_player.hero)[0]

    // selected_role.reserved = true
    // if (!(current_role === "Undecided")){
    //   current_role.reserved  = false
    // }
    // current_player.hero = hero_name
    this.channel.push("assign_hero", {user_tag: this.state.user_tag, game_name: this.state.game_name, hero: hero_name})
  }

  assignRole(role_name, current_player){
    let player = current_player

    let selected_role = this.findRole(role_name)[0]
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

  assignRandomRoles(current_player, roles){
    let index = Math.floor(Math.random() * (roles.length));
    let role  = roles[index];

    this.assignRole(role.name, current_player);
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
      <div className="container">
        <div className="row">
          <div className="roles col-6">
            <h1>Select a Role:</h1>
            <RoleSelector currentPlayer={this.state.current_player} roles={this.state.roles} assignRole={this.assignRole}/>
            <button  type="button" onClick={() => this.assignRandomRoles(this.state.current_player, this.state.roles)} className="btn btn-primary assignRolesButton">
                Random Role
            </button>
          </div>
          <div className="col-6">
            <div className="current_player">
              <h1>Your current role is: {this.state.current_player.role}</h1>
            </div>
            <div className="players">
              <h1>Players</h1>
              <PlayerList user_tag={this.state.user_tag} players={this.state.players} roles={this.state.roles} updateRoles={this.updateRoles} />
            </div>
          </div>
        </div>
        <div>
          Select a hero:
          <HeroSelector heroes={this.state.heroes} currentPlayer={this.state.current_player} assignHero={this.assignHero}/>
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
          <Player user_tag={this.props.user_tag} key={player.id} player_id={player.id} name={player.name} role={player.role} hero={player.hero} roles={this.props.roles} updateRoles={this.props.updateRoles} index={index}/>
        ))
      }
    </ul>
  }
}

class Player extends React.Component {
  render(){
    return (
      <li className="player" key={this.props.id}>
        {this.props.name} has selected role: {this.props.role} and {this.props.hero}
      </li>)
  }
}

class RoleSelector extends React.Component {  
  render(){
    return <RoleList roles={this.props.roles} currentPlayer={this.props.currentPlayer} assignRole={this.props.assignRole} />
  }
}

class HeroSelector extends React.Component {
  render(){
    return <HeroList heroes={this.props.heroes} currentPlayer={this.props.currentPlayer} assignHero={this.props.assignHero} />
  }
}

class HeroList extends React.Component {
  renderHero(hero) {
    return <Hero url={hero.image_url} name={hero.hero_roles.name} key={hero.name} currentPlayer={this.props.currentPlayer} assignHero={this.props.assignHero} />;
  }

  render() {
    return (
      <ul className="hero_list">
        {
          this.props.heroes.map(hero => this.renderHero(hero))
        }
      </ul>
    )
  }
}

class Hero extends React.Component {
  render() {
    return (
      <li className="hero_wrap">
        <a href="#" onClick={(e) => { this.props.assignHero(this.props.name, this.props.currentPlayer)}}>
          <img src={this.props.url} />{this.props.name}
        </a>
      </li>
    )
  }
}

class RoleList extends React.Component { 
  renderRole(role) {
    return <Role name={role.name} key={role.name} currentPlayer={this.props.currentPlayer} assignRole={this.props.assignRole} />;
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
        <button value={this.props.name} className="role btn btn-primary" onClick={(e) => { this.props.assignRole(e.target.value, this.props.currentPlayer)} }>
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