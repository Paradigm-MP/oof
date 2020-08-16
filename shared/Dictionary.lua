Dictionary = class(ValueStorage)

function Dictionary:__init()
    self:InitializeValueStorage(self)

    self:SetValue("current_language", "en")
end

function Dictionary:AddLanguage(lang)
	self:SetValue(lang, {})
end

function Dictionary:AddPhrase(lang, id, phrase)
	local phrases = self:GetValue(lang)
	if not phrases then
		print("No language found with id " .. lang)
	end

	phrases[id] = phrase

	self:SetValue(lang, phrases)
end

function Dictionary:SetLanguage(lang)
	self:SetValue("current_language", lang)
end

function Dictionary:GetLanguage()
	return self:GetValue("current_language")
end

function Dictionary:GetPhrase(language, id)
	if not id then language = self:GetLanguage() end

	local phrases = self:GetValue(language)
	if not phrases then
		print("Trying to get phrase on unlisted language")
		return
	end

	local phrase = phrases[id]
	if not phrase then
		print("Trying to get phrase by wrong identifier")
		return
	end

	return phrase
end