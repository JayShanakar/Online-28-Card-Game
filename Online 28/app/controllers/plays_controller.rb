class PlaysController < ApplicationController
def home
	@player=Player.new
	flash[:notice] = "Welcome !!!"
end
def create
	@presentplayers=Player.find(:all)
	if @presentplayers.size < 4
		@player=Player.new(params[:player])
		@player.points=0
		session[:playername]=@player.name
		if @player.save
			@nop=Player.find(:all)
			for @prplayer in @nop
				if @prplayer.name == session[:playername]
					if @nop.size==1
						@share= Share.new
						@share.playerAid=@prplayer.id
						@share.playerAname=session[:playername]
						@share.biddingProcess=false
						@share.setTrumpProcess=false
						@share.trumpSuit="not set"
						@share.gameOn=true
						@share.trumpCompulsory=false
						@share.save
					elsif @nop.size==2
						@share=Share.find(:all)
						for @s in @share
							@s.playerBid=@prplayer.id
							@s.playerBname=session[:playername]
							@s.update_attributes(params[:s])
						end
					elsif @nop.size==3
						@share=Share.find(:all)
						for @s in @share
							@s.playerCid=@prplayer.id
							@s.playerCname=session[:playername]
							@s.update_attributes(params[:s])
						end
					else @nop.size==4
						@share=Share.find(:all)
						for @s in @share
							@s.playerDid=@prplayer.id
							@s.playerDname=session[:playername]
							@s.update_attributes(params[:s])
						end
					end
					session[:playerid]=@prplayer.id
				end
				
			end
			redirect_to "/plays/main"
		else
			session[:playerid]=nil
			session[:playername]=nil
			render :template=> "plays/home"
		end
	else
		flash[:notice] = "Enough Players !! "
		@player=Player.new
		render :template=> "plays/home"
	end
end
def main
	@player=Player.find(:all)
	if @player.size == 4
		@cards=Card.find(:all)
		if @cards.size == 0
			for i in 1..32
				@card=Card.new
				if i <= 8
					@card.suit="spades"
				elsif i<=16
					@card.suit="hearts"
				elsif i<=24
					@card.suit="diamonds"
				else 
					@card.suit="clubs"
				end
				@card.img="/images/"+@card.suit
				if (i % 8) == 1
					@card.cardno="7"
					@card.points=0
					@card.priority=1
				elsif (i % 8) == 2
					@card.cardno="8"
					@card.points=0
					@card.priority=2
				elsif (i % 8) == 3
					@card.cardno="Q"
					@card.points=0
					@card.priority=3
				elsif (i % 8) == 4
					@card.cardno="K"
					@card.points=0
					@card.priority=4
				elsif (i % 8) == 5
					@card.cardno="10"
					@card.points=1
					@card.priority=5
				elsif (i % 8) == 6
					@card.cardno="A"
					@card.points=1
					@card.priority=6
				elsif (i % 8) == 7
					@card.cardno="9"
					@card.points=2
					@card.priority=7
				elsif (i % 8) == 0
					@card.cardno="J"
					@card.points=3
					@card.priority=8
				end
				@card.img=@card.img+@card.cardno+".jpg"
				@card.dealstatus=false
				@card.playstatus=false
				@card.save
			end
			playerAcards = 0
			playerBcards = 0
			playerCcards = 0
			playerDcards = 0
			for i in 1..16
				n=rand(32)
				@cards=Card.find(:all)
				for @card in @cards
					if @card.id % 32 == n
						if @card.dealstatus==true
							n=(n+1) % 32
							retry if  true
						else
							@plr=Share.find(:all)
							for @p in @plr
								if playerAcards < 4
									playerAcards = playerAcards + 1
									@player= Player.find(@p.playerAid)
								elsif playerBcards < 4
									playerBcards = playerBcards + 1
									@player= Player.find(@p.playerBid)
								elsif playerCcards < 4
									playerCcards = playerCcards + 1
									@player= Player.find(@p.playerCid)
								elsif playerDcards < 4
									playerDcards = playerDcards + 1
									@player= Player.find(@p.playerDid)
								end
								@card.dealstatus=true
								@card.playerid= @player.id
								@card.update_attributes(params[:card])
							end
						end
					end
				end
			end
		end
		@s=Share.find(:all)
		@trk=Trick.find(:all)
		if @s.at(0).trumpCompulsory==true
			flash[:notice]= "Trump Suit Opened !!!"
		elsif (@s.at(0).biddingProcess==false && @s.at(0).setTrumpProcess==false )
			flash[:notice]= "Cards dealt be ready for point bidding !!!"
		elsif @s.at(0).setTrumpProcess==false
			flash[:notice]= "Point bidding started !!!"
		elsif @s.at(0).trumpSuit=="not set"
			flash[:notice]= "Bidding over signalled player please set Trump suit  !!!"
		elsif @trk.size==0 
			flash[:notice]= "All Cards dealt time to start 1st Trick !!!"
		elsif @s.at(0).trickOn==true && @trk.size>0
			flash[:notice]= "Trick going on !"
		elsif @s.at(0).gameOn==true
			flash[:notice]= "Start next Trick !!"
		else
			flash[:notice]="Game completed !! Congratulation Winners !!!"
		end
	else
		flash[:notice] = "Not Enough Players !! wait & refresh !"
	end
	@cards= Card.find(:all, :conditions=>["playerid = ? AND playstatus=?",session[:playerid], false])
end
def bidding
	@share=Share.find(:all)
	if @share.at(0).biddingProcess==false
		@share.at(0).biddingProcess=true
		@share.at(0).maxBidPoints=0
		@share.at(0).signalledPlayername=@share.at(0).playerAname
		@share.at(0).update_attributes(params[:share])
	end
	redirect_to "/plays/main"
end
def bid
	@a=params[:points]
	@share=Share.find(:all)
	if session[:playername] ==	@share.at(0).signalledPlayername
		if @share.at(0).maxBidPoints < @a.to_i
			@share.at(0).maxBidPoints=@a.to_i
			@share.at(0).maxBidder=@share.at(0).signalledPlayername
		else
			if session[:playername]==@share.at(0).playerAname
				@share.at(0).playerAstate="pass"
			elsif session[:playername]==@share.at(0).playerBname
				@share.at(0).playerBstate="pass"
			elsif session[:playername]==@share.at(0).playerCname
				@share.at(0).playerCstate="pass"
			elsif session[:playername]==@share.at(0).playerDname
				@share.at(0).playerDstate="pass"
			end
		end
		@share.at(0).update_attributes(params[:share])
		@share=Share.find(:all)
		@countpass=0
		if @share.at(0).playerAstate=="pass"
			@countpass= @countpass + 1
		end
		if @share.at(0).playerBstate=="pass"
			@countpass= @countpass + 1
		end
		if @share.at(0).playerCstate=="pass"
			@countpass= @countpass + 1
		end
		if @share.at(0).playerDstate=="pass"
			@countpass= @countpass + 1
		end
		if (@countpass >= 3 || @share.at(0).maxBidPoints==28)
			@share.at(0).biddingProcess=false
			@share.at(0).setTrumpProcess=true
			@share.at(0).signalledPlayername=@share.at(0).maxBidder
		else
			if session[:playername]==@share.at(0).playerAname
				if @share.at(0).playerBstate != "pass"
					@share.at(0).signalledPlayername=@share.at(0).playerBname
				elsif @share.at(0).playerCstate != "pass"
					@share.at(0).signalledPlayername=@share.at(0).playerCname
				else @share.at(0).playerDstate != "pass"
					@share.at(0).signalledPlayername=@share.at(0).playerDname
				end
			elsif session[:playername]==@share.at(0).playerBname
				if @share.at(0).playerCstate != "pass"
					@share.at(0).signalledPlayername=@share.at(0).playerCname
				elsif @share.at(0).playerDstate != "pass"
					@share.at(0).signalledPlayername=@share.at(0).playerDname
				else @share.at(0).playerAstate != "pass"
					@share.at(0).signalledPlayername=@share.at(0).playerAname
				end
			elsif session[:playername]==@share.at(0).playerCname
				if @share.at(0).playerDstate != "pass"
					@share.at(0).signalledPlayername=@share.at(0).playerDname
				elsif @share.at(0).playerAstate != "pass"
					@share.at(0).signalledPlayername=@share.at(0).playerAname
				else @share.at(0).playerBstate != "pass"
					@share.at(0).signalledPlayername=@share.at(0).playerBname
				end
			elsif session[:playername]==@share.at(0).playerDname
				if @share.at(0).playerAstate != "pass"
					@share.at(0).signalledPlayername=@share.at(0).playerAname
				elsif @share.at(0).playerBstate != "pass"
					@share.at(0).signalledPlayername=@share.at(0).playerBname
				else @share.at(0).playerCstate != "pass"
					@share.at(0).signalledPlayername=@share.at(0).playerCname
				end
			end
		end
		@share.at(0).update_attributes(params[:share])
	end
	redirect_to "/plays/main"
end
def trumpset
	@b=params[:trumpsuit]
	@share=Share.find(:all)
	if session[:playername] ==	@share.at(0).signalledPlayername
		@share.at(0).trumpSuit = @b
		@share.at(0).trumpShow=false
		@share.at(0).signalledPlayername=""
		@share.at(0).trickOn=false
		@share.at(0).update_attributes(params[:share])
		playerAcards = 0
		playerBcards = 0
		playerCcards = 0
		playerDcards = 0
		for i in 1..16
			n=rand(32)
			@cards=Card.find(:all)
			for @card in @cards
				if @card.id % 32 == n
					if @card.dealstatus==true
						n=(n+1) % 32
						retry if  true
					else
						@plr=Share.find(:all)
						for @p in @plr
							if playerAcards < 4
								playerAcards = playerAcards + 1
								@player= Player.find(@p.playerAid)
							elsif playerBcards < 4
								playerBcards = playerBcards + 1
								@player= Player.find(@p.playerBid)
							elsif playerCcards < 4
								playerCcards = playerCcards + 1
								@player= Player.find(@p.playerCid)
							elsif playerDcards < 4
								playerDcards = playerDcards + 1
								@player= Player.find(@p.playerDid)
							end
							@card.dealstatus=true
							@card.playerid= @player.id
							@card.update_attributes(params[:card])
						end
					end
				end
			end
		end
	end
	redirect_to "/plays/main"
end
def trick
	@share= Share.find(:all)
	if @share.at(0).trickOn==false
		@share.at(0).trickOn=true
		@share.at(0).trumpCompulsory=false
		@share.at(0).update_attributes(params[:share])
		@t=Trick.find(:all)
		@trick=Trick.new
		@trick.trickno=@t.size + 1
		if @trick.trickno==1
			@trick.trickleadname=@share.at(0).playerAname
		else
			@trick.trickleadname=@t.at(@t.size - 1).trickwinnername
		end
		@share=Share.find(:all)
		@share.at(0).signalledPlayername=@trick.trickleadname
		@share.at(0).update_attributes(params[:share])
		@trick.highestPriority=0
		@trick.trumpPriority=0
		@trick.tricksuit=""
		@trick.trickpoints=0
		@trick.trump=false
		@trick.update_attributes(params[:trick])
	end
	redirect_to "/plays/main"
end
def move
	@cardid=params[:cardid].to_i
	@card=Card.find(:all, :conditions=>["id=?",@cardid])
	@trick=Trick.find(:all)
	@prcards=Card.find(:all, :conditions=>["playerid=? AND playstatus=? AND suit=?",session[:playerid],false,@trick.at(@trick.size-1).tricksuit])
	@share=Share.find(:all)
	@prtrumpcards=Card.find(:all, :conditions=>["playerid=? AND playstatus=? AND suit=?",session[:playerid],false,@share.at(0).trumpSuit])
	if session[:playername] ==	@share.at(0).signalledPlayername 
		if ((@trick.at(@trick.size-1).tricksuit=="" || @prcards.size==0 || @card.at(0).suit==@trick.at(@trick.size-1).tricksuit) && (@share.at(0).trumpCompulsory==false || @card.at(0).suit==@share.at(0).trumpSuit || @prtrumpcards.size==0))			
			@m=Move.find(:all, :conditions=>["trickno=?",@trick.size])
			@move=Move.new
			@move.trickno=@trick.size
			@move.playername=session[:playername]
			@move.moveno=@m.size + 1
			@card.at(0).playstatus=true
			@card.at(0).update_attributes(params[:card])
			@move.cardsuit=@card.at(0).suit
			@move.cardno=@card.at(0).cardno
			@move.cardpoints=@card.at(0).points
			if @move.moveno==1
				@trick.at(@trick.size-1).tricksuit=@move.cardsuit
			end
			if (@share.at(0).trumpShow==true && @card.at(0).suit==@share.at(0).trumpSuit)
				@trick.at(@trick.size-1).trump=true
			end
			@trick.at(@trick.size-1).trickpoints = @trick.at(@trick.size-1).trickpoints + @move.cardpoints
			if (@trick.at(@trick.size-1).highestPriority < @card.at(0).priority && @card.at(0).suit==@trick.at(@trick.size-1).tricksuit && @trick.at(@trick.size-1).trump==false)
				@trick.at(@trick.size-1).highestPriority = @card.at(0).priority
				@trick.at(@trick.size-1).trickwinnername= @move.playername
			end
			if (@trick.at(@trick.size-1).trump==true && @trick.at(@trick.size-1).trumpPriority < @card.at(0).priority && @card.at(0).suit==@share.at(0).trumpSuit)
				@trick.at(@trick.size-1).trumpPriority = @card.at(0).priority
				@trick.at(@trick.size-1).trickwinnername= @move.playername
			end
			if @move.moveno==4
				@share.at(0).signalledPlayername=""
				@share.at(0).trickOn=false
				@player=Player.find(:all, :conditions=>["name=?",@trick.at(@trick.size-1).trickwinnername])
				@player.at(0).points=@player.at(0).points+@trick.at(@trick.size-1).trickpoints
				@player.at(0).update_attributes(params[:player])
				if @trick.size==8
					@share.at(0).gameOn=false
					@pa=Player.find(:all, :conditions=>["name=?",@share.at(0).playerAname])
					@pb=Player.find(:all, :conditions=>["name=?",@share.at(0).playerBname])
					@pc=Player.find(:all, :conditions=>["name=?",@share.at(0).playerCname])
					@pd=Player.find(:all, :conditions=>["name=?",@share.at(0).playerDname])
					@pacpoints=@pa.at(0).points + @pc.at(0).points
					@pbdpoints=@pb.at(0).points + @pd.at(0).points
					if ((@share.at(0).maxBidder==@share.at(0).playerAname || @share.at(0).maxBidder==@share.at(0).playerCname) && @share.at(0).trumpShow==true) 
						if @pacpoints >= @share.at(0).maxBidPoints
							@share.at(0).gamewinner=@share.at(0).playerAname + " & " + @share.at(0).playerCname 
							@share.at(0).winnerpoints=@pacpoints
						else
							@share.at(0).gamewinner=@share.at(0).playerBname + " & " + @share.at(0).playerDname 
							@share.at(0).winnerpoints=@pbdpoints
						end
					elsif @share.at(0).trumpShow==true
						if @pbdpoints >= @share.at(0).maxBidPoints
							@share.at(0).gamewinner=@share.at(0).playerBname + " & " + @share.at(0).playerDname 
							@share.at(0).winnerpoints=@pbdpoints
						else
							@share.at(0).gamewinner=@share.at(0).playerAname + " & " + @share.at(0).playerCname 
							@share.at(0).winnerpoints=@pacpoints
						end
					else
						@share.at(0).gamewinner=" Game Cancelled as trump suit not opened"
					end
				end
			elsif @share.at(0).signalledPlayername==@share.at(0).playerAname
				@share.at(0).signalledPlayername=@share.at(0).playerBname
			elsif @share.at(0).signalledPlayername==@share.at(0).playerBname
				@share.at(0).signalledPlayername=@share.at(0).playerCname
			elsif @share.at(0).signalledPlayername==@share.at(0).playerCname
				@share.at(0).signalledPlayername=@share.at(0).playerDname
			elsif @share.at(0).signalledPlayername==@share.at(0).playerDname
				@share.at(0).signalledPlayername=@share.at(0).playerAname
			end
			@share.at(0).trumpCompulsory=false
			@share.at(0).update_attributes(params[:share])
			@trick.at(@trick.size-1).update_attributes(params[:trick])
			@move.update_attributes(params[:move])
		end
	end
	redirect_to "/plays/main"
end
def asktrump
	@share= Share.find(:all)
	@trick=Trick.find(:all)
	@m=Move.find(:all, :conditions=>["trickno=?",@trick.size])
	if (session[:playername] ==	@share.at(0).signalledPlayername && @m.size != 0 && @share.at(0).trumpShow==false && @share.at(0).trickOn==true)
		@prsuit=Card.find(:all, :conditions=>["playerid=? AND playstatus=? AND suit=?",session[:playerid],false,@trick.at(@trick.size-1).tricksuit])
		if @prsuit.size==0
			@share.at(0).trumpShow=true
			@share.at(0).trumpCompulsory=true
			@share.at(0).update_attributes(params[:share])
		end
	end
	redirect_to "/plays/main"
end
def claimpair
	@share= Share.find(:all)
	if (session[:playername] ==	@share.at(0).signalledPlayername && @share.at(0).trumpShow==true)
		if (session[:playername] == @share.at(0).playerAname || session[:playername] == @share.at(0).playerCname)
			@pa=Player.find(:all, :conditions=>["name=?",@share.at(0).playerAname])			
			@pc=Player.find(:all, :conditions=>["name=?",@share.at(0).playerCname])
			@pacpoints=@pa.at(0).points + @pc.at(0).points
			if @pacpoints > 0
				@pcards=Card.find(:all, :conditions=>["playerid=? AND playstatus=? AND suit=? AND ( cardno=? OR cardno=? )",session[:playerid],false,@share.at(0).trumpSuit,"K","Q"])
				if @pcards.size==2
					if @share.at(0).maxBidPoints >= 18
						if (@share.at(0).maxBidder==@share.at(0).playerAname || @share.at(0).maxBidder==@share.at(0).playerCname)
							@share.at(0).maxBidPoints=@share.at(0).maxBidPoints - 4
						else
							@share.at(0).maxBidPoints=@share.at(0).maxBidPoints + 4
						end
					else
						if (@share.at(0).maxBidder==@share.at(0).playerAname || @share.at(0).maxBidder==@share.at(0).playerCname)
							@share.at(0).maxBidPoints=@share.at(0).maxBidPoints - 2
						else
							@share.at(0).maxBidPoints=@share.at(0).maxBidPoints + 2
						end
					end
				end
			end
		end
		if (session[:playername] == @share.at(0).playerBname || session[:playername] == @share.at(0).playerDname)
			@pb=Player.find(:all, :conditions=>["name=?",@share.at(0).playerBname])
			@pd=Player.find(:all, :conditions=>["name=?",@share.at(0).playerDname])
			@pbdpoints=@pb.at(0).points + @pd.at(0).points
			if @pbdpoints > 0
				@pcards=Card.find(:all, :conditions=>["playerid=? AND playstatus=? AND suit=? AND ( cardno=? OR cardno=? )",session[:playerid],false,@share.at(0).trumpSuit,"K","Q"])
				if @pcards.size==2
					if @share.at(0).maxBidPoints >= 18
						if (@share.at(0).maxBidder==@share.at(0).playerBname || @share.at(0).maxBidder==@share.at(0).playerDname)
							@share.at(0).maxBidPoints=@share.at(0).maxBidPoints - 4
						else
							@share.at(0).maxBidPoints=@share.at(0).maxBidPoints + 4
						end
					else
						if (@share.at(0).maxBidder==@share.at(0).playerBname || @share.at(0).maxBidder==@share.at(0).playerDname)
							@share.at(0).maxBidPoints=@share.at(0).maxBidPoints - 2
						else
							@share.at(0).maxBidPoints=@share.at(0).maxBidPoints + 2
						end
					end
				end				
			end
		end
		@share.at(0).update_attributes(params[:share])
	end
	redirect_to "/plays/main"
end
def destroy
	@players=Player.find(:all)
	for player in @players
		player.destroy
	end
	@cards=Card.find(:all)
	for card in @cards
		card.destroy
	end
	@tricks=Trick.find(:all)
	for trick in @tricks
		trick.destroy
	end
	@moves=Move.find(:all)
	for move in @moves
		move.destroy
	end
	@shares=Share.find(:all)
	for share in @shares
		share.destroy
	end
	redirect_to "/plays/home"
end
end
