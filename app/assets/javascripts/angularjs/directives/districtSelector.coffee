@app.directive 'districtSelector', ['City', (City)->
  directiveCache =
    restrict: 'A'
    scope:
      region: '=region'
    template: """
      <div class='city-group'>
        <select ng-model='province_region' ng-options='province.value as province.label for province in provinces' ng-change='changeProvinceHandler();'>
          <option value=''>--省份--</option>
        </select>
        <select ng-model='city_region' ng-options='city.value as city.label for city in cities' ng-change='changeCityHandler();'>
          <option value=''>--城市--</option>
        </select>
        <select ng-model='district_region' ng-options='district.value as district.label for district in districts' ng-change='changeDistrictHandler();'>
          <option value=''>--地区--</option>
        </select>
      </div>
    """
    replace: false
    link: (scope, element, attrs, controller)->
      dataParser = (data) ->
        _result = []
        for d in data.data
          _result.push
            label: d.data[0]
            value: d.data[1]
        _result

      setCities = (id) ->
        if !!id
          City.get { id: id }, (cities) ->
            scope.cities = dataParser cities
        else
          scope.districts = []
      setDistricts = (id) ->
        if !!id
          City.get { id: id }, (districts) ->
            scope.districts = dataParser districts

      generateRegion = (region, length) ->
        _result = region.toString()
        _result = _result.split('').slice(0, length)
        for i in [0...(6 - length)]
          _result.push '0'
        _result.join('')

      initedFlag = false
      initRegion = (region) ->
        region = region and region.toString().trim()
        if !!region
          initedFlag = true
          # SetProvince
          scope.province_region = generateRegion(region, 2)
          City.getProvinces (provinces) ->
            scope.provinces = dataParser(provinces)
          # SetCity
          scope.city_region = generateRegion(region, 4)
          City.get { id: scope.province_region }, (cities) ->
            scope.cities = dataParser(cities)
          # setDistrict
          scope.district_region = region
          City.get { id: scope.city_region }, (districts) ->
            scope.districts = dataParser(districts)

      City.getProvinces (provinces) ->
        scope.provinces = dataParser provinces
      scope.$watch 'region', (newVal, oldVal) ->
        initRegion(newVal) unless initedFlag

      scope.changeProvinceHandler = () ->
        scope.region = scope.province_region
        setCities(scope.province_region)
        scope.districts = []
      scope.changeCityHandler = () ->
        scope.region = scope.city_region
        setDistricts(scope.city_region)
        scope.districts = []
      scope.changeDistrictHandler = () ->
        scope.region = scope.district_region

]
