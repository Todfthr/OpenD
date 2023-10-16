import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat8 "mo:base/Nat8";
import Cycles "mo:base/ExperimentalCycles";
import NFTActorClass "../NFT/nft";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import List "mo:base/List";

actor DNFT {

  var mapOfNfts = HashMap.HashMap<Principal, NFTActorClass.NFT>(1, Principal.equal, Principal.hash);
  var mapOfOwners = HashMap.HashMap<Principal, List.List<Principal>>(1, Principal.equal, Principal.hash);

  public shared(msg) func mint(imageData: [Nat8], name: Text) : async Principal {
    let owner : Principal = msg.caller;

    Debug.print(debug_show(Cycles.balance()));
    Cycles.add(100_500_000_000);
    
    let newNft = await NFTActorClass.NFT(name, owner, imageData);
    Debug.print(debug_show(Cycles.balance()));

    let newNFTPrincipal = await newNft.getCanisterId();

    mapOfNfts.put(newNFTPrincipal, newNft);
    addToOwnershipMap(owner, newNFTPrincipal);

    return newNFTPrincipal;
  };

  private func addToOwnershipMap(owner: Principal, nftId: Principal){

    var ownedNfts : List.List<Principal> = switch (mapOfOwners.get(owner)) {
      case null List.nil<Principal>();
      case (?result) result;
    };

    ownedNfts := List.push(nftId, ownedNfts);
    mapOfOwners.put(owner, ownedNfts)

  };

  public query func getOwnedNfts(user: Principal) : async [Principal] {
    var userNfts: List.List<Principal> = switch (mapOfOwners.get(user)) {
      case null List.nil<Principal>();
      case (?result) result;
    };

    return List.toArray(userNfts);
  }

}
