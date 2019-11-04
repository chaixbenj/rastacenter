# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

module License

def License.createdomaine(newlogin)
	if User.where(:login => newlogin).first == nil
domaine = Domaine.new(guid: (SecureRandom.uuid).to_s)
domaine.save

version = Version.new(name: 'current', domaine_id: domaine.id)
version.save

role = Role.new(name: 'admin', droits: '111111111111111111111111111111111111111111111111', domaine_id: domaine.id)
role.save

password = "admin"
_encryptedpassword = Commun.get_encrypted_password(password)
admin = User.new(login: newlogin, pwd: _encryptedpassword[0..49], username: newlogin, is_admin: 1, domaine_id: domaine.id)
admin.save

userpref = UserPreference.new(user_id: admin.id, domaine_id: domaine.id)
userpref.save

listetesttype = Liste.new(domaine_id: domaine.id, code: "TEST_TYPE", name: "Test type", description: "type de test", is_deletable: 0)
listetesttype.save
	rec = ListeValue.new(domaine_id: domaine.id, liste_id: listetesttype.id, value: "WEB", is_modifiable: 0)
	rec.save
	rec = ListeValue.new(domaine_id: domaine.id, liste_id: listetesttype.id, value: "WebService", is_modifiable: 0)
	rec.save
	rec = ListeValue.new(domaine_id: domaine.id, liste_id: listetesttype.id, value: "MobileNativeApp", is_modifiable: 0)
	rec.save
	rec = ListeValue.new(domaine_id: domaine.id, liste_id: listetesttype.id, value: "Free", is_modifiable: 0)
	rec.save

listeteststatus = Liste.new(domaine_id: domaine.id, code: "TEST_STATE", name: "Test status", description: "status de test", is_deletable: 0)
	listeteststatus.save
	rec = ListeValue.new(domaine_id: domaine.id, liste_id: listeteststatus.id, value: "Not Ready", is_modifiable: 1)
	rec.save
	rec = ListeValue.new(domaine_id: domaine.id, liste_id: listeteststatus.id, value: "Ready", is_modifiable: 1)
	rec.save
	rec = ListeValue.new(domaine_id: domaine.id, liste_id: listeteststatus.id, value: "Deprecated", is_modifiable: 1)
	rec.save

listetestlevel = Liste.new(domaine_id: domaine.id, code: "TEST_LEVEL", name: "Test level", description: "niveau de test", is_deletable: 0)
	listetestlevel.save
	rec = ListeValue.new(domaine_id: domaine.id, liste_id: listetestlevel.id, value: "acceptance", is_modifiable: 1)
	rec.save
	rec = ListeValue.new(domaine_id: domaine.id, liste_id: listetestlevel.id, value: "integration composant", is_modifiable: 1)
	rec.save
	rec = ListeValue.new(domaine_id: domaine.id, liste_id: listetestlevel.id, value: "integration fonctionnelle", is_modifiable: 1)
	rec.save

listeworkflowstatus = Liste.new(domaine_id: domaine.id, code: "WKF_STATUS", name: "Workflow element status", description: "status disponibles pour les élements de workflow", is_deletable: 0)
	listeworkflowstatus.save
	recdebut = ListeValue.new(domaine_id: domaine.id, liste_id: listeworkflowstatus.id, value: "new", is_modifiable: 1)
	recdebut.save
	rec = ListeValue.new(domaine_id: domaine.id, liste_id: listeworkflowstatus.id, value: "close", is_modifiable: 1)
	rec.save

listepriority = Liste.new(domaine_id: domaine.id, code: "PRIORITY", name: "Priority", description: "Priorité", is_deletable: 0)
	listepriority.save
	rec = ListeValue.new(domaine_id: domaine.id, liste_id: listepriority.id, value: "High", is_modifiable: 1)
	rec.save
	rec = ListeValue.new(domaine_id: domaine.id, liste_id: listepriority.id, value: "Medium", is_modifiable: 1)
	rec.save
	rec = ListeValue.new(domaine_id: domaine.id, liste_id: listepriority.id, value: "Low", is_modifiable: 1)
	rec.save

vconfenv = ConfigurationVariable.new(domaine_id: domaine.id, name: "$environment", description: "environnement sous test : DEVELOPPEMENT, INTEGRATION, PREPRODUCTION...\nValeurs définies dans 'environnement'", no_value: 1, is_deletable: 0)
	vconfenv.save

vconfjdd = ConfigurationVariable.new(domaine_id: domaine.id, name: "$data_set", description: "jeu de donnée...\nValeurs définies dans 'jeu de donnée'", no_value: 1, is_deletable: 0)
	vconfjdd.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfjdd.id, value: "default", is_modifiable: 0)
	rec.save

vconfbrowser = ConfigurationVariable.new(domaine_id: domaine.id, name: "$browser", description: "navigateur", no_value: 0, is_deletable: 0)
vconfbrowser.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfbrowser.id, value: "FFOX", is_modifiable: 0)
	rec.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfbrowser.id, value: "CHRO", is_modifiable: 0)
	rec.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfbrowser.id, value: "EDGE", is_modifiable: 0)
	rec.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfbrowser.id, value: "IE", is_modifiable: 0)
	rec.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfbrowser.id, value: "SAFA", is_modifiable: 0)
	rec.save

vconfbrowsersize = ConfigurationVariable.new(domaine_id: domaine.id, name: "$browser_size", description: "taille du navigateur 'largeur'x'hauteur'", no_value: 0, is_deletable: 0)
	vconfbrowsersize.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfbrowsersize.id, value: "fullsize", is_modifiable: 0)
	rec.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfbrowsersize.id, value: "1440x900", is_modifiable: 0)
	rec.save

vconflaunchpf = ConfigurationVariable.new(domaine_id: domaine.id, name: "$launch_platform", description: "Plateforme local de lancement du test", no_value: 0, is_deletable: 0)
	vconflaunchpf.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconflaunchpf.id, value: "WIN", is_modifiable: 0)
	rec.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconflaunchpf.id, value: "MAC", is_modifiable: 0)
	rec.save
  rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconflaunchpf.id, value: "LINUX", is_modifiable: 0)
	rec.save

vconfexecdevice = ConfigurationVariable.new(domaine_id: domaine.id, name: "$execution_test_device", description: "Matériel sur lequel exécuter le test", no_value: 0, is_deletable: 0)
	vconfexecdevice.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfexecdevice.id, value: "PC", is_modifiable: 0)
	rec.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfexecdevice.id, value: "MAC", is_modifiable: 0)
	rec.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfexecdevice.id, value: "Mobile Android", is_modifiable: 0)
	rec.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfexecdevice.id, value: "Mobile iOS", is_modifiable: 0)
	rec.save
  rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfexecdevice.id, value: "LINUX", is_modifiable: 0)
	rec.save

vconfphoto = ConfigurationVariable.new(domaine_id: domaine.id, name: "$screenshot", description: "Prise de photo", no_value: 0, is_deletable: 0, is_boolean: 1)
	vconfphoto.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfphoto.id, value: "true", is_modifiable: 0)
	rec.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfphoto.id, value: "false", is_modifiable: 0)
	rec.save

vconfcompphoto = ConfigurationVariable.new(domaine_id: domaine.id, name: "$screenshot_diff", description: "Comparaison des photos", no_value: 0, is_deletable: 0, is_boolean: 1)
	vconfcompphoto.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfcompphoto.id, value: "false", is_modifiable: 0)
	rec.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfcompphoto.id, value: "true", is_modifiable: 0)
	rec.save

vconfappium = ConfigurationVariable.new(domaine_id: domaine.id, name: "$appium_capabilities", description: "Appium capabilities pour test mobile\nValeurs définie dans 'appium capabilities'", no_value: 1, is_deletable: 0)
	vconfappium.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfappium.id, value: "android", is_modifiable: 0)
	rec.save

vconfmaxwait = ConfigurationVariable.new(domaine_id: domaine.id, name: "$max_seconds_wait", description: "Temps d'attente maximum pour l'identification d'éléments", no_value: 0, is_deletable: 0, is_numeric: 1)
	vconfmaxwait.save
	rec = ConfigurationVariableValue.new(domaine_id: domaine.id, configuration_variable_id: vconfmaxwait.id, value: "60", is_modifiable: 0)
	rec.save

datasetdefault = DataSet.new(name: 'default', version_id: version.id, description: 'default data set', domaine_id: domaine.id, is_default: 1)
datasetdefault.save
datasetdefault.current_id = datasetdefault.id
datasetdefault.save

appiumcap = AppiumCap.new(name: 'android', version_id: version.id, description: 'android appium capabilities', domaine_id: domaine.id)
appiumcap.save
appiumcap.current_id = appiumcap.id
appiumcap.save
	capv1 =AppiumCapValue.new(domaine_id: domaine.id, name: 'platformName')
	capv1.save
		rec = AppiumCapValue.new(init_value_id: capv1.id, domaine_id: domaine.id, name: 'platformName', appium_cap_id: appiumcap.id, value: 'android')
rec.save
	capv2 =AppiumCapValue.new(domaine_id: domaine.id, name: 'platformVersion')
	capv2.save
		rec = AppiumCapValue.new(init_value_id: capv2.id, domaine_id: domaine.id, name: 'platformVersion', appium_cap_id: appiumcap.id, value: nil)
rec.save
	capv3 =AppiumCapValue.new(domaine_id: domaine.id, name: 'deviceName')
	capv3.save
		rec = AppiumCapValue.new(init_value_id: capv3.id, domaine_id: domaine.id, name: 'deviceName', appium_cap_id: appiumcap.id, value: nil)
rec.save
	capv4 =AppiumCapValue.new(domaine_id: domaine.id, name: 'browserName')
	capv4.save
		rec = AppiumCapValue.new(init_value_id: capv4.id, domaine_id: domaine.id, name: 'browserName', appium_cap_id: appiumcap.id, value: nil)
rec.save
	capv5 =AppiumCapValue.new(domaine_id: domaine.id, name: 'browser')
	capv5.save
		rec = AppiumCapValue.new(init_value_id: capv5.id, domaine_id: domaine.id, name: 'browser', appium_cap_id: appiumcap.id, value: nil)
rec.save
	capv6 =AppiumCapValue.new(domaine_id: domaine.id, name: 'orientation')
	capv6.save
		rec = AppiumCapValue.new(init_value_id: capv6.id, domaine_id: domaine.id, name: 'orientation', appium_cap_id: appiumcap.id, value: "PORTRAIT")
rec.save
	capv7 =AppiumCapValue.new(domaine_id: domaine.id, name: 'nativeWebScreenshot', is_boolean: 1)
	capv7.save
		rec = AppiumCapValue.new(init_value_id: capv7.id,domaine_id: domaine.id, name: 'nativeWebScreenshot', appium_cap_id: appiumcap.id, value: "true", is_boolean: 1)
rec.save
	capv8 =AppiumCapValue.new(domaine_id: domaine.id, name: 'app')
	capv8.save
		rec = AppiumCapValue.new(init_value_id: capv8.id, domaine_id: domaine.id, name: 'app', appium_cap_id: appiumcap.id, value: nil)
rec.save



rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_getLocationXY", description: "retourne la position de l'élément répondant à la stratégie de recherche", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "element|$|element|$|",
	code: "puts '_getLocationXY ' + element.strategy.to_s + ' ' + element.path.to_s
datenow = Time.now.localtime
i_retry = 0
elem = nil
found = false
begin
	elem = $webdriver.find_element(element.strategy, element.path)
	found = true
rescue Exception => e
	puts e.message
	i_retry += 1
	sleep 1/10
end while found == false and i_retry < 300 and (Time.now.localtime-datenow) < $max_seconds_wait

if found
	x = elem.location.x
	y = elem.location.y
	$report.pass(\"...x : \#{x} ...y : \#{y}\")
else
	x = nil
	y = nil
	$report.fail(e.message)
end

puts \"...x : \#{x} ...y : \#{y}\"
return x, y")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_scrollToElement", description: "scroll au niveau de l'élément pour qu'il soit visible à l'écran", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "element|$|element|$|",
	code: "puts 'scrollToElement ' + element.strategy.to_s + ' ' + element.path.to_s
datenow = Time.now.localtime
i_retry = 0
elem = nil
found = false
begin
	elem = $webdriver.find_element(element.strategy, element.path)
	found = true
rescue Exception => e
	puts e.message
	i_retry += 1
	sleep 1/10
end while found == false and i_retry < 300 and (Time.now.localtime-datenow) < $max_seconds_wait

if found
	$report.pass
	scrollencours=$webdriver.execute_script(\"arguments[0].scrollIntoView(true);\" , elem)
	sleep 1/4
else
	$report.fail(e.message)
end
return elem")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_openNewTab", description: "scroll au niveau de l'élément pour qu'il soit visible à l'écran", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "",
	code: "puts 'openNewTab '
init_tab = $webdriver.window_handle
open_tab = nil
tabs = $webdriver.window_handles
nb_tabs = tabs.count.to_i
$webdriver.execute_script( \"window.open()\" )
begin
	sleep 1
end while $webdriver.window_handles.count.to_i == nb_tabs
newtabs = $webdriver.window_handles
newtabs.each do |newtab|
	isnotnewtab = false
	for i in 0..nb_tabs-1
		if newtab == tabs[i]
			isnotnewtab = true
		end
	end
	if isnotnewtab == false
		open_tab = newtab
		$webdriver.switch_to.window(open_tab)
		break
	end
end
return init_tab, open_tab")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_selectTab", description: "scroll au niveau de l'élément pour qu'il soit visible à l'écran", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "value|$|tab|$|",
	code: "puts 'selectTab ' + tab.to_s
$webdriver.switch_to.window(tab)")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_closeTab", description: "scroll au niveau de l'élément pour qu'il soit visible à l'écran", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "value|$|tabtoclose|$|value|$|tabtoswitch|$|",
	code: "puts 'closeTab ' + tabtoclose.to_s  + ' switchTo ' + tabtoswitch.to_s
$webdriver.switch_to.window(tabtoclose)
$webdriver.execute_script( \"window.close()\" )
$webdriver.switch_to.window(tabtoswitch)")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_waitWebPageLoadComplete", description: "attend que la page web soit complètement chargée", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "",
	code: "puts 'waitWebPageLoadComplete'
begin
	sleep 1/4
end until $webdriver.execute_script(\"return document.readyState\") == 'complete'")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_click", description: "clique sur l'élément", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "element|$|element|$|",
	code: "puts 'click ' + element.strategy.to_s + ' ' + element.path.to_s
datenow = Time.now.localtime
i_retry = 0
clicked = false
elem = nil
begin
	elem = $webdriver.find_element(element.strategy, element.path)
	if $nativeApp.to_s == 'true'
		$TA.tap(element: elem).release.perform
	else
      if $execution_test_device.start_with? \"Mobile\"
		$webdriver.execute_script(\"arguments[0].click();\" , elem)
	  else
        elem.click
	  end
 	end
	clicked = true
rescue Exception => e
	puts e.message
	i_retry += 1
	sleep 1/10
end while clicked == false and i_retry < 300 and (Time.now.localtime-datenow) < $max_seconds_wait

if clicked
	$report.pass
else
	$report.fail(e.message)
end

return elem")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_setValue", description: "saisie un texte dans l'élément", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "element|$|element|$|value|$|text|$|",
	code: "puts 'setValue ' + element.strategy.to_s + ' ' + element.path.to_s + ' value : ' + text
datenow = Time.now.localtime
i_retry = 0
found = false
elem = nil
begin
	elem = $webdriver.find_element(element.strategy, element.path)
	if $nativeApp.to_s == 'true'
		$TA.tap(element: elem).release.perform
		begin
			len_textalreadyin=elem.attribute(\"value\").length
		rescue
			len_textalreadyin=elem.text.length
		end
		elem.send_keys [:end]
		begin
			elem.send_keys [:backspace]
			len_textalreadyin=len_textalreadyin-1
		end while len_textalreadyin>0
		elem.send_keys text
	else
		elem.clear
		elem.send_keys text
		elem.send_keys :tab
	end
	found = true
rescue Exception => e
	puts e.message
	i_retry += 1
	sleep 1/10
end while found == false and i_retry < 300 and (Time.now.localtime-datenow) < $max_seconds_wait

if found
	$report.pass
	begin
		$driver.hide_keyboard
	rescue
	end
else
	$report.fail(e.message)
end

return elem")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_selectInListBox", description: "choisit l'option dans une listbox élément (type select) ", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "element|$|listbox|$|value|$|optionlabel|$|",
	code: "puts 'selectInListBox ' + listbox.strategy.to_s + ' ' + listbox.path.to_s + ' value : ' + optionlabel
datenow = Time.now.localtime
i_retry = 0
clicked = false
elem = nil
begin
	element = $webdriver.find_element(listbox.strategy, listbox.path)
	elems=$webdriver.find_elements(:xpath, \"//option\")
	found_elem_text = nil
	if elems != nil
		elems.each do |elem|
			if elem.text.include? optionlabel
				found_elem_text = elem.text
				Selenium::WebDriver::Support::Select.new(element).select_by(:text, found_elem_text)
				break
			end
		end
	end
	clicked = true
rescue Exception => e
	puts e.message
	i_retry += 1
	sleep 1/10
end while clicked == false and i_retry < 300 and (Time.now.localtime-datenow) < $max_seconds_wait

if clicked
	$report.pass
else
	$report.fail(e.message)
end

return element")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_switchMainFrame", description: "positionnement dans la fenêtre principale, si on s'est positionné ailleurs auparavant", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "",
	code: "puts 'switchMainFrame '
$webdriver.switch_to.default_content")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_switchToIframe", description: "positionnement dans une iframe pour intéragir sur ses compsants", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "element|$|iframe|$|",
	code: "puts 'switchMainFrame ' + iframe.strategy.to_s + ' ' + iframe.path.to_s
datenow = Time.now.localtime
i_retry = 0
i_frame = nil
found = false
begin
	i_frame = $webdriver.find_element(element.strategy, element.path)
	$webdriver.switch_to.frame(i_frame)
	found = true
rescue Exception => e
	puts e.message
	i_retry += 1
	sleep 1/10
end while found == false and i_retry < 300 and (Time.now.localtime-datenow) < $max_seconds_wait

if found
	$report.pass
else
	$report.fail(e.message)
end

return i_frame")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_goToUrl", description: "appel d'un page par son url", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "value|$|url|$|",
	code: "puts 'goToUrl ' + url.to_s
$webdriver.get url")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_getText", description: "renvoi le texte d'un élément", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "element|$|element|$|",
	code: "puts 'getText ' + element.strategy.to_s + ' ' + element.path.to_s
datenow = Time.now.localtime
i_retry = 0
text = nil
found = false
begin
	elem = $webdriver.find_element(element.strategy, element.path)
	text = elem.text
	found = true
rescue Exception => e
	puts e.message
	i_retry += 1
	sleep 1/10
end while found == false and i_retry < 300 and (Time.now.localtime-datenow) < $max_seconds_wait

if found
	$report.log(text)
else
	$report.fail(e.message)
end

puts '...text :' + text
return text")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_getAttribute", description: "renvoi la valeur d'attribut d'un élément", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "element|$|element|$|value|$|attribut|$|",
	code: "puts 'getAttribute ' + element.strategy.to_s + ' ' + element.path.to_s + ' attribute : ' + attribut.to_s
datenow = Time.now.localtime
i_retry = 0
valeur = nil
found = false
begin
	elem = $webdriver.find_element(element.strategy, element.path)
	valeur = elem.attribute(attribut)
	found = true
rescue Exception => e
	puts e.message
	i_retry += 1
	sleep 1/10
end while found == false and i_retry < 300 and (Time.now.localtime-datenow) < $max_seconds_wait

if found
	$report.log(valeur)
else
	$report.fail(e.message)
end

puts '...attribute :' + valeur
return valeur")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_getCount", description: "renvoi le nombre d'éléments du type recherché", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "element|$|element|$|",
	code: "puts '_getCount ' + element.strategy.to_s + ' ' + element.path.to_s
datenow = Time.now.localtime
i_retry = 0
count = nil
found = false
begin
	elem = $webdriver.find_elements(element.strategy, element.path)
	count = elem.count
	found = true
rescue Exception => e
	puts e.message
	i_retry += 1
	sleep 1/10
end while found == false and i_retry < 300 and (Time.now.localtime-datenow) < $max_seconds_wait

if found
	$report.log(count)
else
	$report.fail(e.message)
end

puts '...count :' + count.to_s
return count")
rec.save
rec.current_id = rec.id
rec.save

rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_exists", description: "l'élément existe-t-il maintenant sans attente", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "element|$|element|$|",
	code: "puts 'exists ' + element.strategy.to_s + ' ' + element.path.to_s
elem = nil
begin
	elem = $webdriver.find_element(element.strategy, element.path)
rescue
	elem = nil
end
if elem != nil
	exist = true
else
	exist = false
end
puts '...exists : ' + exist.to_s
$report.log(exist.to_s)
return exist")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_isVisible", description: "l'élément existe-t-il et est-il visible", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "element|$|element|$|",
	code: "puts 'isVisible ' + element.strategy.to_s + ' ' + element.path.to_s
datenow = Time.now.localtime
i_retry = 0
visible = false
found = false
begin
	elem = $webdriver.find_element(element.strategy, element.path)
	visible = elem.displayed?
	found = true
rescue Exception => e
	puts e.message
	i_retry += 1
	sleep 1/10
end while found == false and i_retry < 300 and (Time.now.localtime-datenow) < $max_seconds_wait

if found
	$report.log(visible.to_s)
else
	$report.fail(e.message)
end

puts '...visible : ' + visible.to_s
return visible")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_isTextInPageSource", description: "le texte se trouve-t-il dans le source de la page", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "value|$|text|$|",
	code: "puts 'isTextInPageSource ' + text.to_s
exist=false
if $webdriver.page_source.include? text
	exist=true
end
puts '...exists : ' + exist.to_s
$report.log(exist.to_s)
return exist")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_storeData", description: "enregistre des données sous un nom spécifique pour utilisation ultérieure", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "value|$|dataname|$|value|$|datavalue|$|",
	code: "puts 'storeData ' + dataname.to_s + ' <= ' + datavalue
payloadh = {:key => \"\#{dataname}\",
:value => \"\#{datavalue.gsub('\"', '\\\\\"').gsub('\\n', '\\\\n')}\"}
payload = JSON.generate(payloadh)
RestClient::Request.execute(
	:method => :post,
	:url => $urlpostresult.gsub('postresult', 'storedata'),
	:user => $currentrun,
	:password => $currentuuid,
	:payload => payload,
	:headers => {:content_type => 'application/json'})")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_storedDataGet", description: "récupère des données enregistrer par l'action _storeData()", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "value|$|dataname|$|",
	code: "puts 'storedDataGet ' + dataname.to_s
response = RestClient::Request.execute(
	:method => :get,
	:url => $urlpostresult.gsub('postresult', 'getdata') + \"?key=\#{URI.encode(dataname)}\",
	:user => $currentrun,
	:password => $currentuuid,
	:headers => {:content_type => 'application/json'})
rep = JSON.parse(response.body, :quirks_mode => true)
datavalue = rep[\"value\"]
puts '...value : ' + datavalue
return datavalue")
rec.save
rec.current_id = rec.id
rec.save


rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_callWS", description: "appel webservice", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "value|$|url|$|value|$|method|$|value|$|payload|$|value|$|headers|$|value|$|user|$|value|$|password|$|",
	code: "puts '_callWS ' + url.to_s + ' method : ' + method.to_s + ', user : ' + user.to_s + ', password : ' + password.to_s + ', payload : ' + payload.to_s + ', headers : ' + headers.to_s
begin
case method
	when \"post\"
		method = :post
	when \"get\"
		method = :get
	when \"put\"
		method = :put
	when \"delete\"
		method = delete
	end
 response=RestClient::Request.execute(
	:method => method,
	:url => url,
	:payload => payload,
	:user =>user,
	:password => password ,
	:headers => JSON.parse(headers, :quirks_mode => true))
	$report.pass(response.to_s)
rescue Exception => e
	$report.fail(e.message)
end
puts '...reponse : ' + response.to_s
 return response")
rec.save
rec.current_id = rec.id
rec.save

rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_checkEquals", description: "vérification égalité de 2 valeurs", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "value|$|value1|$|value|$|value2|$|",
	code: "puts 'checkEquals ' + value1.to_s + ' =? ' + value2.to_s
if value1 == value2
	$report.pass
  puts 'equals'
else
	$report.fail(value1, value2)
  puts 'not equals'
end")
rec.save
rec.current_id = rec.id
rec.save

rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_jsAlertAccept", description: "valider l'alert javascript", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "",
	code: "puts 'jsAlertAccept '
datenow = Time.now.localtime
i_retry = 0
clicked = false
begin
	js_popup = $webdriver.switch_to.alert
	js_popup.accept
	clicked = true
rescue Exception => e
	puts e.message
	i_retry += 1
	sleep 1/10
end while clicked == false and i_retry < 300 and (Time.now.localtime-datenow) < $max_seconds_wait

if clicked
	$report.pass
else
	$report.fail(e.message)
end
")
rec.save
rec.current_id = rec.id
rec.save

rec = Action.new(domaine_id: domaine.id, version_id: version.id, name: "_jsAlertDismiss", description: "annuler l'alert javascript", callable_in_proc: 1, action_admin_id: admin.id, is_modifiable: 0,
	parameters: "",
	code: "puts 'jsAlertDismiss '
datenow = Time.now.localtime
i_retry = 0
clicked = false
begin
	js_popup = $webdriver.switch_to.alert
	js_popup.dismiss
	clicked = true
rescue Exception => e
	puts e.message
	i_retry += 1
	sleep 1/10
end while clicked == false and i_retry < 300 and (Time.now.localtime-datenow) < $max_seconds_wait

if clicked
	$report.pass
else
	$report.fail(e.message)
end
")
rec.save
rec.current_id = rec.id
rec.save

rec = RequiredGem.new(domaine_id: domaine.id, version_id: version.id, gems: "require 'rubygems'\nrequire 'rest-client'\nrequire 'json'\nrequire 'date'\n")
rec.save
rec.current_id = rec.id
rec.save


rec = Findstrategie.new(name: ':xpath', domaine_id: domaine.id)
rec.save
rec = Findstrategie.new(name: ':name', domaine_id: domaine.id)
rec.save
rec = Findstrategie.new(name: ':id', domaine_id: domaine.id)
rec.save
rec = Findstrategie.new(name: ':css', domaine_id: domaine.id)
rec.save
rec = Findstrategie.new(name: ':link', domaine_id: domaine.id)
rec.save

root_folder = SheetFolder.new(domaine_id: domaine.id, name: 'root', can_be_updated: 0)
root_folder.save
workflow = Sheet.new(domaine_id: domaine.id, sheet_folder_id: root_folder.id, name: 'bug', type_sheet: 'workflow', private: 0, owner_user_id: admin.id, version_id: version.id, user_cre: admin.id)
workflow.save
workflow.current_id = workflow.id
workflow.save
startnode = Node.new( domaine_id: domaine.id, sheet_id: workflow.id, id_externe: 1,x: 1, y: 1, name: recdebut.value, type_node: 'card',obj_type: 'startworkflow', obj_id: recdebut.id)
startnode.save
rec = TypeFiche.new(name: 'bug', domaine_id: domaine.id, is_system: 0, color: '#ff0000', sheet_id: workflow.id)
rec.save

return domaine.id, admin.id
else
return nil
end

end
end
