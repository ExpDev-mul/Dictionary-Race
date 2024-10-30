-->> Placed in here so in case StarterGui resets, the playlist should remain as normal.
-->> Services
local soundService = game:GetService("SoundService");

-->> Constants
local DELAY_BETWEEN = 3;
local playlist = {"Mysterious","Relax"}

-->> Functions
local playlistIndex = 0;
function Loop()
	playlistIndex += 1
	if (playlistIndex > #playlist) then
		playlistIndex = playlistIndex - #playlist
	end;
	
	local sound = soundService:WaitForChild(playlist[playlistIndex]);
	if not sound.IsLoaded then
		sound.Loaded:Wait()
	end;
	
	sound:Play()
	
	task.delay(sound.TimeLength/sound.PlaybackSpeed, function()
		-->> In case something needs to be done here.
		task.delay(DELAY_BETWEEN, function()
			Loop()
		end)
	end)
end;

Loop()