GOOGLE_MAPS_API_URL = 'https://maps.googleapis.com/maps/api/geocode/json?latlng='
GOOGLE_MAPS_API_KEY = '&key=AIzaSyCs7eId7TLd46-tJH-9NeT4KMZHf2qOKzI'

Template.hello.events
    'click button': ->
      MeteorCamera.getPicture {}, (e,r)->
        if e?
          alert (e.message)
        else
          l = Geolocation.latLng()
          if l
            url = GOOGLE_MAPS_API_URL + l.lat + ',' + l.lng + GOOGLE_MAPS_API_KEY
            $.getJSON url, (res)->
              if res.status is 'OK'
                a = res.results[0].formatted_address
                z = res.results[1].address_components[0].long_name
              myColl.insert {time:new Date(), pic:r, loc:l, address:a, zip:z}
          uploadCount = (Session.get 'mycount') or 0
          uploadCount += 1
          Session.set 'mycount', uploadCount

    'click img.small-image':(e,t)->
      uploadCount = (Session.get 'mycount') or 0
      if uploadCount > 0
        id = e.target.getAttribute 'data-id'
        myColl.remove id
        Session.set 'mycount', uploadCount - 1
      else
        alert "You cannot delete more pictures than you uploaded (#{uploadCount} pictures)"

Template.hello.helpers
  pos:->
    Geolocation.latLng()
  pictures:(l)->
    if l
      url = GOOGLE_MAPS_API_URL + l.lat + ',' + l.lng + GOOGLE_MAPS_API_KEY
      zipCode = (Session.get 'zip') or ''
      $.getJSON url, (res)->
        Session.set 'zip', res.results[1].address_components[0].long_name if res.status is 'OK'
        return
      myColl.find({zip: zipCode}, {sort:{time:-1}}) if zipCode
  addr:(l)->
    if l
      url = GOOGLE_MAPS_API_URL + l.lat + ',' + l.lng + GOOGLE_MAPS_API_KEY
      $.getJSON url, (res)->
        Session.set '_address', res.results[0].formatted_address if res.status is 'OK'
        return
      Session.get '_address'
