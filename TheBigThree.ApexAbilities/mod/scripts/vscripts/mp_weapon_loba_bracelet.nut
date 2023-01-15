global function loba_bracelet_Init
global function OnProjectileCollision_weapon_loba_bracelet
#if SERVER
global function GetClosestValidPosition
#endif

void function loba_bracelet_Init() {
  printt("''''''''''''''''''''''''''#####################''''''''''''''''''''''")
  PrecacheWeapon( "mp_weapon_loba_bracelet" )
}

//! ---------------------

void function OnProjectileCollision_weapon_loba_bracelet( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	#if SERVER
  printt("______________________ LESSGO ____________________________")
    entity player = projectile.GetOwner()
		if ( hitEnt.GetClassName() != "func_brush" )
		{
      thread TeleportPlayer( player, pos, projectile, normal )
      projectile.Destroy()
		}
	#endif
}

#if SERVER
void function TeleportPlayer( entity player, vector position, entity projectile, vector normal )
{
  wait 0.2

  float distance = TraceLineSimple( position, position - < 0, 0, 9999 >, projectile )

  vector endPos = position - < 0, 0, distance - 10.0 >

  printt(endPos, PlayerCanTeleportHere( player, endPos, projectile ))

  if( PlayerCanTeleportHere( player, endPos, projectile ) )
  {
    player.ForceStand()         // TO-DO plz fix 3 lines
    player.SetOrigin( endPos )
    player.UnforceStand()
  } else {
    float toCeiling = TraceLineSimple( position, position + < 0, 0, GetEntHeight( player ) >, projectile )
    
    player.SetOrigin( endPos + normal * GetEntDepth( player ) - < 0, 0, GetEntHeight( player ) - toCeiling > )
    DropToGround( player )    // TO-DO fix
  }
}

vector function GetClosestValidPosition( entity player )
{
  if( PlayerCanTeleportHere( player, player.GetOrigin() ))
    return player.GetOrigin()

  float length = 5 //start value to check the distance, increaces every iteration
  array<vector> norms = [ < 1, 0, 0>, < 0, 1, 0>, < -1, 0, 0>, < 0, -1, 0>, < 1, 1, 0 >,
                          < -1, -1, 0>, < 1, -1, 0>, < -1, 1, 0 >, < 0, 0, 1 >, < 0, 0, -1 > ] 
  float height = 20
  while( 1 )
  {
    foreach(vector norm in norms)
    {
      for(float h = -1 ; h<= 1 ; h++)
      {
        vector endPos =  player.GetOrigin() + norm * length + <0, 0, h * height>

        if( PlayerCanTeleportHere( player, endPos ) )
        {
          // DrawGlobal( "line", player.GetOrigin(), endPos )
          return endPos
        }
      }
    }
    length += 10
  }
  unreachable
}

#endif