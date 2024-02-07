extends Control

# City Information
@onready var city_name = $InformationLeft/Location/CityName
@onready var latitude = $InformationLeft/Location/Latitude
@onready var longitude = $InformationLeft/Location/Longitude

# Weather Information
@onready var weather_name = $InformationLeft/Weather/WeatherName
@onready var weather_description = $InformationLeft/Weather/WeatherDescription
@onready var weather_icon = $InformationLeft/Weather/Icon/WeatherIcon

# Temperature Information
@onready var temperature_value = $InformationLeft/Temperature/TemperatureValue
@onready var temperature_feels_like = $InformationLeft/Temperature/TemperatureFeelsLike
@onready var pressure = $InformationLeft/Temperature/Pressure

# Wind Information
@onready var wind_speed = $InformationLeft/Wind/WindSpeed
@onready var wind_deg = $InformationLeft/Wind/WindDeg

# Additional Weather Information
@onready var clouds = $InformationRight/Cloud/Clouds
@onready var visibility = $InformationRight/Cloud/Visibility
@onready var humidity = $InformationRight/Humidity/Humidity
@onready var max_temp = $InformationRight/Humidity/MaxTemp
@onready var min_temp = $InformationRight/Humidity/MinTemp

# Search and UI Elements
@onready var search_bar = $SearchBar
@onready var animation_player = $AnimationPlayer
@onready var loading = $Loading

# Data Display
@onready var data_display = $ResponseData

#URL
@onready var url = $URL

# HTTP Request
@onready var http_request = $HTTPRequest

# API Key Handling
@export var api_key := "YOUR_API_KEY" # Place your api_key here, get it from https://home.openweathermap.org/api_keys
@onready var invalid_api_key = $InvalidAPIKey
@onready var api_key_input = $InvalidAPIKey/Body/API_KEY_Input

var city := ""

func _ready():
	randomize()
	city = "America"
	search_bar.grab_focus()
	update()

func update():
	if city == "":
		return
	
	http_request.request("https://api.openweathermap.org/data/2.5/weather?q=" + city + "&appid=" + api_key)
	url.text = "https://api.openweathermap.org/data/2.5/weather?q=" + city + "&appid=" + api_key
	
	set_loading(true)

func _on_http_request_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
	randomize()
	if response_code == 404:
		print("Error")
		OS.alert("City not found", "Error")
		set_loading(false)
		return
	
	elif response_code == 401:
		print("Error")
		invalid_api_key.popup_centered()
		api_key_input.text = ""
		set_loading(false)
		return
	
	data_display.text = "Response: " + "\n"

	var data = JSON.parse_string(body.get_string_from_utf8())

	for each_data in data:
		print(each_data + " = ", data[each_data])
		var value = data[each_data]

		if each_data == "name":
			city_name.text = "City: " + value
		
		elif each_data == "weather":
			weather_name.text = "Weather: " + value[0].main
			weather_description.text = "Description: " + value[0].description
			weather_icon.texture = load("res://Assets/Weather Icons/" + str(value[0].icon) + "@2x.png")
		
		elif each_data == "main":
			temperature_value.text = "Temperature: " + str(int(convert_kelvin_to_celsius(value.temp))) + "°C"
			temperature_feels_like.text = "Feels Like: " + str(int(convert_kelvin_to_celsius(value.feels_like))) + "° C"
			pressure.text = "Pressure: " + str(value.pressure) + " hPa"
			min_temp.text = "Min Temp: " + str(int(convert_kelvin_to_celsius(value.temp_min))) + "°C"
			max_temp.text = "Max Temp: " + str(int(convert_kelvin_to_celsius(value.temp_max))) + "°C"
		
			humidity.text = "Humidity: " + str(value.humidity) + "%"
		elif each_data == "coord":
			latitude.text = "Latitude: " + str(value.lat) + "° N"
			longitude.text = "Longitude: " + str(value.lon) + "° E"
		
		elif each_data == "wind":
			wind_speed.text = "Wind Speed: " + str(value.speed) + " m/s"
			wind_deg.text = "Direction: " + str(value.deg) + "°"
		
		elif each_data == "clouds":
			clouds.text = "Cloudiness: " + str(value.all) + "%"
		
		elif each_data == "visibility":
			visibility.text = "Visibility: " + str(value/1000) + " km"
		
		data_display.text += each_data + " = " + str(value) + "\n"

	set_loading(false)

func convert_kelvin_to_celsius(value: float):
	return value - 273.15 # Fahrenheit Formula = (value - 273.15) * 9/5 + 32

func convert_wind_speed(value):
	return value * 3.6

func _on_search_bar_text_submitted(new_text: String):
	city = new_text
	update()

func set_loading(is_loading: bool):
	if is_loading:
		animation_player.play("loading")
	else:
		animation_player.stop()
	loading.visible = is_loading

func _on_subscribe_button_pressed():
	OS.shell_open("https://www.youtube.com/channel/UC8l-lYjEmIYoxvvIPmE4HPw")

func _on_link_meta_clicked(meta: String):
	OS.shell_open(meta)

func replace_api_key(new_api_key: String):
	api_key = new_api_key
	update()

func _on_api_key_input_text_submitted(new_text: String):
	replace_api_key(new_text)

func _on_invalid_api_key_confirmed():
	replace_api_key(api_key_input.text)
