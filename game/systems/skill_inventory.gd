extends RefCounted
var ranks: Dictionary={"sword":0,"vitality":0}
var charges: Dictionary={"tide":0,"heal":0}
func load_state(data: Dictionary) -> void:
 var saved_ranks: Dictionary=data.get("ranks",{})
 var saved_charges: Dictionary=data.get("charges",{})
 ranks={"sword":clampi(int(saved_ranks.get("sword",0)),0,5),"vitality":clampi(int(saved_ranks.get("vitality",0)),0,3)}
 charges={"tide":clampi(int(saved_charges.get("tide",0)),0,3),"heal":clampi(int(saved_charges.get("heal",0)),0,3)}
func export_state() -> Dictionary:return {"ranks":ranks.duplicate(),"charges":charges.duplicate()}
func offers() -> Array:
 return [
 {"id":"sword","title":"BLADE DISCIPLINE","description":"Permanent +15% sword damage per rank.","price":180+int(ranks.sword)*140,"owned":"RANK %d / 5"%ranks.sword,"capped":ranks.sword>=5},
 {"id":"vitality","title":"IRON HEART","description":"Permanent +20 maximum health per rank.","price":220+int(ranks.vitality)*180,"owned":"RANK %d / 3"%ranks.vitality,"capped":ranks.vitality>=3},
 {"id":"tide","title":"TIDAL NOVA","description":"Q · Nearby foes: 85 damage + space to escape. 3 uses.","price":160,"owned":"%d / 3 CHARGES"%charges.tide,"capped":charges.tide>0},
 {"id":"heal","title":"CRIMSON ELIXIR","description":"H · Restore 55 health. 3 uses. Works underwater.","price":120,"owned":"%d / 3 CHARGES"%charges.heal,"capped":charges.heal>0}]
func purchase(id: String, wallet: int) -> Dictionary:
 for offer in offers():
  if offer.id!=id:continue
  if offer.capped:return {"ok":false,"wallet":wallet,"message":"Rank complete" if ranks.has(id) else "Use remaining charges before refilling"}
  if wallet<int(offer.price):return {"ok":false,"wallet":wallet,"message":"Need %d more coins"%(int(offer.price)-wallet)}
  if ranks.has(id):ranks[id]+=1
  else:charges[id]=3
  return {"ok":true,"wallet":wallet-int(offer.price),"message":"Training learned" if ranks.has(id) else "Three charges stocked"}
 return {"ok":false,"wallet":wallet,"message":"Unknown skill"}
func consume(id: String) -> bool:
 if not charges.has(id) or charges[id]<=0:return false
 charges[id]-=1
 return true
