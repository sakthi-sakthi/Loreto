///<reference name="MicrosoftAjax.js"/>

// ------------------------------------------------------------------------------------------------
// Copyright (C) ArtemBG.
// ------------------------------------------------------------------------------------------------
// GoogleMap4.debug.js
// GoogleMap Control v4.1 javascipt library (debug).
//
// Assembly:    Artem.GooleMap
// Version:     4.1.0.0
// Project:     http://googlemap.codeplex.com
// Website:     http://artembg.com
// Author:      Velio Ivanov - velio@artembg.com
// License:     Microsoft Permissive License (Ms-PL) v1.1
//              http://www.codeplex.com/googlemap/license
// API:         http://code.google.com/apis/maps/

// Function.Delegate //////////////////////////////////////////////////////////////////////////////

Function.Delegate = {

    // Static Methods -----------------------------------------------------------------------------

    call: function Function$Delegate$call(instance, method) {
        Function.Delegate.create(instance, method).call(instance, arguments);
    },

    callFromString: function Function$Delegate$callFromString(instance, methodString) {
        Function.Delegate.createFromString(instance, methodString).call(instance, arguments);
    },

    createFromString: function $Function$Delegate$createFromString(instance, methodString) {
        var rex = new RegExp("\\(.*\\)");
        if (rex.test(methodString))
            return function() { eval(methodString); };
        else {
            var method = eval(methodString);
            return Function.Delegate.create(instance, method);
        }
    }

};

// Artem.Web namespace ////////////////////////////////////////////////////////////////////////////

if (!Artem) var Artem = {};
if (!Artem.Web) Artem.Web = {};

// GoogleMapView enum /////////////////////////////////////////////////////////////////////////////

Artem.Web.GoogleMapView = {

    // Fields ------------------------------------------------------------------------------------

    Normal: 0,
    Satellite: 1,
    Hybrid: 2,
    Physical: 3,
    MoonElevation: 4,
    MoonVisible: 5,
    MarsElevation: 6,
    MarsVisible: 7,
    MarsInfrared: 8,
    SkyVisible: 9,
    Satellite3D: 10,
    MapMakerNormal: 11,
    MapMakerHybrid: 12,

    // Methods ------------------------------------------------------------------------------------

    convert: function Artem$Web$GoogleMapView$convert(gmapType) {
        switch (gmapType) {
            case G_SATELLITE_MAP:
                return Artem.Web.GoogleMapView.Satellite;
            case G_HYBRID_MAP:
                return Artem.Web.GoogleMapView.Hybrid;
            case G_PHYSICAL_MAP:
                return Artem.Web.GoogleMapView.Physical;
            case G_MOON_ELEVATION_MAP:
                return Artem.Web.GoogleMapView.MoonElevation;
            case G_MOON_VISIBLE_MAP:
                return Artem.Web.GoogleMapView.MoonVisible;
            case G_MARS_ELEVATION_MAP:
                return Artem.Web.GoogleMapView.MarsElevation;
            case G_MARS_VISIBLE_MAP:
                return Artem.Web.GoogleMapView.MarsVisible;
            case G_MARS_INFRARED_MAP:
                return Artem.Web.GoogleMapView.MarsInfrared;
            case G_SKY_VISIBLE_MAP:
                return Artem.Web.GoogleMapView.SkyVisible;
            case G_SATELLITE_3D_MAP:
                return Artem.Web.GoogleMapView.Satellite3D;
            case G_MAPMAKER_NORMAL_MAP:
                return Artem.Web.GoogleMapView.MapMakerNormal;
            case G_MAPMAKER_HYBRID_MAP:
                return Artem.Web.GoogleMapView.MapMakerHybrid;
            default:
                return Artem.Web.GoogleMapView.Normal;
        }
    }

};

// OpenInfoBehaviour enum /////////////////////////////////////////////////////////////////////////

Artem.Web.OpenInfoBehaviour = {
    Click: 0,
    DoubleClick: 1,
    MouseDown: 2,
    MouseOut: 3,
    MouseOver: 4,
    MouseUp: 5
};

// GoogleManager class ////////////////////////////////////////////////////////////////////////////

Artem.Web.GoogleManager = {

    // Static Fields ------------------------------------------------------------------------------

    CurrentMap: null,
    Disposed: false,
    Initialized: false,
    Saved: false,
    Maps: new Array(), // here is kept a reference to all maps on the page

    // Static Methods -----------------------------------------------------------------------------

    addMap: function Artem$Web$GoogleManager$addMap(map) {
        for (var i = 0; i < this.Maps.length; i++) {
            if (map.ClientID == this.Maps[i].ClientID) return;
        }
        this.Maps[this.Maps.length] = (this.CurrentMap = map);
    },

    dispose: function Artem$Web$GoogleManager$dispose() {
        if (typeof (Sys) != 'undefined') {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            if (!prm.get_isInAsyncPostBack()) GUnload();
        }
        else
            GUnload();
    },

    initialize: function Artem$Web$GoogleManager$initialize() {
        if (!this.Initialized) {
            this.Initialized = true;
            this.Saved = false;
            if (!GBrowserIsCompatible()) throw "Your browser is not google maps api compatible!";

            var handler = Function.Delegate.create(this, this.dispose);
            if (typeof (Sys) != 'undefined') {
                var prm = Sys.WebForms.PageRequestManager.getInstance();
                prm.add_beginRequest(handler);
            }
            Function.Handler.add(window, "unload", handler);
        }
    },

    save: function Artem$Web$GoogleManager$save() {
        try {
            for (var i = 0; i < this.Maps.length; i++) {
                try {
                    this.Maps[i].save();
                }
                catch (ex1) { }
            }
        }
        catch (ex) { }
    },

    // Type ---------------------------------------------------------------------------------------
    __type: "Artem.Web.GoogleManager"
};

// GoogleBounds class /////////////////////////////////////////////////////////////////////////////

Artem.Web.GoogleBounds = function Artem$Web$GoogleBounds(bounds) {
    this._init(bounds);
};

Artem.Web.GoogleBounds.prototype = {

    // Fields -------------------------------------------------------------------------------------

    GBounds: null,

    // Methods ------------------------------------------------------------------------------------

    _init: function Artem$Web$GoogleBounds$_init(bounds) {
        this.GBounds = bounds;
    },

    save: function Artem$Web$GoogleBounds$save() {
        var state = "{";
        if (this.GBounds) {
            var sw = this.GBounds.getSouthWest();
            var ne = this.GBounds.getNorthEast();
            state += "\"SouthWest\":{\"Latitude\":" + sw.lat() + ",\"Longitude\":" + sw.lng() + "},";
            state += "\"NorthEast\":{\"Latitude\":" + ne.lat() + ",\"Longitude\":" + ne.lng() + "}";
        }
        state += "}";
        return state;
    },

    // Type ---------------------------------------------------------------------------------------
    __type: "Artem.Web.GoogleBounds"
};

// GoogleDirection class //////////////////////////////////////////////////////////////////////////

Artem.Web.GoogleDirection = function Artem$Web$GoogleDirection(map, config) {
    this._init(map, config);
};

Artem.Web.GoogleDirection.prototype = {

    // Fields -------------------------------------------------------------------------------------

    GDirections: null,
    Locale: null,
    Query: null,
    PreserveViewport: null,
    RoutePanelId: null,

    // Methods ------------------------------------------------------------------------------------

    _init: function Artem$Web$GoogleDirection$_init(map, config) {
        this.Locale = config.Locale;
        this.Query = config.Query;
        this.RoutePanelId = config.RoutePanelId;
        this.PreserveViewport = config.PreserveViewport;
        // origin
        var pane = null;
        if (this.RoutePanelId) pane = document.getElementById(this.RoutePanelId);
        this.GDirections = new GDirections(map.GMap, pane);
    },

    loadDefault: function Artem$Web$GoogleDirection$loadDefault() {
        var options;
        if (this.Locale && this.PreserveViewport) {
            options = { locale: this.Locale, preserveViewport: this.PreserveViewport };
        } else if (this.Locale) {
            options = { locale: this.Locale };
        } else if (this.PreserveViewport) {
            options = { preserveViewport: this.PreserveViewport };
        }
        this.load(this.Query, options);
    },

    save: function Artem$Web$GoogleDirection$save() {
        var state = "{";
        state += "\"Locale\":\"" + this.Locale + "\",";
        state += "\"Query\":\"" + this.Query + "\",";
        state += "\"RoutePanelId\":\"" + this.RoutePanelId + "\",";
        state += "\"PreserveViewport\":\"" + this.PreserveViewport + "\",";
        // distance
        var distance = this.getDistance();
        state += "\"Distance\":{\"Meters\":" + distance.meters + ",\"Html\":\"" + distance.html + "\"},";
        // duration
        var duration = this.getDuration();
        state += "\"Duration\":{\"Seconds\":" + duration.seconds + ",\"Html\":\"" + duration.html + "\"},";
        // bounds
        var bounds = new Artem.Web.GoogleBounds(this.getBounds());
        state += "\"Bounds\":";
        state += bounds.save();
        //
        state += "}";
        return state;
    },

    // Google Maps API Wrapped --------------------------------------------------------------------

    clear: function Artem$Web$GoogleDirection$clear() {
        this.GDirections.clear();
    },

    getBounds: function Artem$Web$GoogleDirection$getBounds() {
        return this.GDirections.getBounds();
    },

    getCopyrightsHtml: function Artem$Web$GoogleDirection$getCopyrightsHtml() {
        return this.GDirections.getCopyrightsHtml();
    },

    getDistance: function Artem$Web$GoogleDirection$getDistance() {
        return this.GDirections.getDistance();
    },

    getDuration: function Artem$Web$GoogleDirection$getDuration() {
        return this.GDirections.getDuration();
    },

    getGeocode: function Artem$Web$GoogleDirection$getGeocode(i) {
        return this.GDirections.getGeocode(i);
    },

    getMarker: function Artem$Web$GoogleDirection$getMarker(i) {
        return this.GDirections.getMarker(i);
    },

    getNumGeocodes: function Artem$Web$GoogleDirection$getNumGeocodes() {
        return this.GDirections.getNumGeocodes();
    },

    getNumRoutes: function Artem$Web$GoogleDirection$getNumRoutes() {
        return this.GDirections.getNumRoutes();
    },

    getPolyline: function Artem$Web$GoogleDirection$getPolyline() {
        return this.GDirections.getPolyline();
    },

    getRoute: function Artem$Web$GoogleDirection$getRoute(i) {
        return this.GDirections.getRoute(i);
    },

    getSummaryHtml: function Artem$Web$GoogleDirection$getSummaryHtml() {
        return this.GDirections.getSummaryHtml();
    },

    getStatus: function Artem$Web$GoogleDirection$getStatus() {
        return this.GDirections.getStatus();
    },

    load: function Artem$Web$GoogleDirection$load(query, options) {
        this.GDirections.load(query, options);
    },

    loadFromWaypoints: function Artem$Web$GoogleDirection$loadFromWaypoints(waypoints, options) {
        this.GDirections.loadFromWaypoints(waypoints, options);
    },

    // Type ---------------------------------------------------------------------------------------
    __type: "Artem.Web.GoogleDirection"
};

// GooglePolygon class ////////////////////////////////////////////////////////////////////////////

Artem.Web.GooglePolygon = function Artem$Web$GooglePolygon(map, index, config) {
    this._init(map, index, config);
};

Artem.Web.GooglePolygon.prototype = {

    // Fields -------------------------------------------------------------------------------------

    GPolygon: null,
    Map: null,
    Index: null,
    Clickable: null,
    EnableDrawing: null,
    EnableEditing: null,
    FillColor: null,
    FillOpacity: null,
    Points: null,
    StrokeColor: null,
    StrokeOpacity: null,
    StrokeWeight: null,

    ClientEvents: null,
    ServerEvents: null,

    // Methods ------------------------------------------------------------------------------------

    _init: function Artem$Web$GooglePolygon$_init(map, index, config) {

        this.Map = map;
        this.Index = index;
        this.Clickable = config.Clickable;
        this.EnableDrawing = config.EnableDrawing;
        this.EnableEditing = config.EnableEditing;
        this.FillColor = config.FillColor;
        this.FillOpacity = config.FillOpacity;
        this.Points = config.Points;
        this.StrokeColor = config.StrokeColor;
        this.StrokeOpacity = config.StrokeOpacity;
        this.StrokeWeight = config.StrokeWeight;

        // origin
        var points = new Array();
        var options = new Object();
        if (this.Points) {
            for (var i = 0; i < this.Points.length; i++) {
                points.push(new GLatLng(this.Points[i].Latitude, this.Points[i].Longitude));
            }
        }
        options.clickable = this.Clickable;

        this.GPolygon = new GPolygon(points,
                            this.StrokeColor, this.StrokeWeight, this.StrokeOpacity, this.FillColor, this.FillOpacity, options);
        if (this.EnableDrawing) this.enableDrawing();
        if (this.EnableEditing) this.enableEditing();

        // events
        if (map.PolygonEvents) {
            this.ClientEvents = map.PolygonEvents.ClientEvents;
            this.ServerEvents = map.PolygonEvents.ServerEvents;
        }
        this.attachEvents(this.ClientEvents, true);
        this.attachEvents(this.ServerEvents, false);
    },

    attachEvents: function Artem$Web$GooglePolygon$attachEvents(events, clients) {
        if (events) {
            var key;
            for (var i = 0; i < events.length; i++) {
                key = events[i].Key;
                if (clients) {
                    GEvent.addListener(this.GPolygon, key,
                        Function.Delegate.createFromString(this, events[i].Handler));
                }
                else {
                    var handler = events[i].Handler;
                    var delegate = Function.Delegate.create(this, this.raiseEvent);
                    GEvent.addListener(this.GPolygon, key, function(args) {
                        delegate.call(this, handler, args);
                    });
                }
            }
        }
    },

    raiseEvent: function Artem$Web$GooglePolygon$raiseEvent(handler, args) {
        this.Map.save();
        handler = handler.replace("INDEX", this.Index);
        handler = handler.replace("ARGS", args);
        eval(handler);
    },

    save: function Artem$Web$GooglePolygon$save() {
        var state = "{";
        //
        state += "\"Clickable\":" + this.Clickable + ",";
        state += "\"FillColor\":\"" + this.FillColor + "\",";
        state += "\"FillOpacity\":" + this.FillOpacity + ",";
        state += "\"StrokeColor\":\"" + this.StrokeColor + "\",";
        state += "\"StrokeOpacity\":" + this.StrokeOpacity + ",";
        state += "\"StrokeWeight\":" + this.StrokeWeight + ",";
        // points
        if (this.Points) {
            state += "\"Points\":[";
            var point;
            for (var i = 0; i < this.Points.length; i++) {
                point = this.Points[i];
                state += "{\"Latitude\":" + point.Latitude + ",\"Longitude\":" + point.Longitude + "},";
            }
            state = state.substr(0, state.length - 1);
            state += "],";
        }
        // bounds
        var bounds = new Artem.Web.GoogleBounds(this.getBounds());
        state += "\"Bounds\":";
        state += bounds.save();
        //
        state += "}";
        return state;
    },

    // Google Maps API Wrapped --------------------------------------------------------------------

    deleteVertex: function Artem$Web$GooglePolygon$deleteVertex(index) {
        this.GPolygon.deleteVertex(index);
    },

    disableEditing: function Artem$Web$GooglePolygon$disableEditing() {
        this.GPolygon.disableEditing();
    },

    enableDrawing: function Artem$Web$GooglePolygon$enableDrawing(opts) {
        this.GPolygon.enableDrawing(opts);
    },

    enableEditing: function Artem$Web$GooglePolygon$enableEditing(opts) {
        this.GPolygon.enableEditing(opts);
    },

    getArea: function Artem$Web$GooglePolygon$getArea() {
        return this.GPolygon.getArea();
    },

    getBounds: function Artem$Web$GooglePolygon$getBounds() {
        return this.GPolygon.getBounds();
    },

    getVertex: function Artem$Web$GooglePolygon$getVertex() {
        return this.GPolygon.getVertex();
    },

    getVertexCount: function Artem$Web$GooglePolygon$getVertexCount() {
        return this.GPolygon.getVertexCount();
    },

    hide: function Artem$Web$GooglePolygon$hide() {
        this.GPolygon.hide();
    },

    insertVertex: function Artem$Web$GooglePolygon$insertVertex(index, latlng) {
        this.GPolygon.insertVertex();
    },

    isHidden: function Artem$Web$GooglePolygon$isHidden() {
        return this.GPolygon.isHidden();
    },

    show: function Artem$Web$GooglePolygon$show() {
        this.GPolygon.show();
    },

    supportsHide: function Artem$Web$GooglePolygon$supportsHide() {
        return this.GPolygon.supportsHide();
    },

    setFillStyle: function Artem$Web$GooglePolygon$setFillStyle(style) {
        this.GPolygon.setFillStyle(style);
    },

    setStrokeStyle: function Artem$Web$GooglePolygon$setStrokeStyle(style) {
        this.GPolygon.setStrokeStyle(style);
    },

    // Type ---------------------------------------------------------------------------------------
    __type: "Artem.Web.GooglePolygon"
};

// GooglePolyline class ///////////////////////////////////////////////////////////////////////////

Artem.Web.GooglePolyline = function Artem$Web$GooglePolyline(map, index, config) {
    this._init(map, index, config);
};

Artem.Web.GooglePolyline.prototype = {

    // Fields -------------------------------------------------------------------------------------

    GPolyline: null,
    Map: null,
    Index: null,
    Clickable: null,
    Color: null,
    Geodesic: null,
    Opacity: null,
    Points: null,
    Weight: null,

    ClientEvents: null,
    ServerEvents: null,

    // Methods ------------------------------------------------------------------------------------

    _init: function Artem$Web$GooglePolyline$_init(map, index, config) {

        this.Map = map;
        this.Index = index;
        this.Clickable = config.Clickable;
        this.Color = config.Color;
        this.Geodesic = config.Geodesic;
        this.Opacity = config.Opacity;
        this.Points = config.Points;
        this.Weight = config.Weight;

        // origin
        var points = new Array();
        var options = new Object();
        if (this.Points) {
            for (var i = 0; i < this.Points.length; i++) {
                points.push(new GLatLng(this.Points[i].Latitude, this.Points[i].Longitude));
            }
        }
        options.clickable = this.Clickable;
        options.geodesic = this.Geodesic;
        this.GPolyline = new GPolyline(points, this.Color, this.Weight, this.Opacity, options);

        // events
        if (map.PolylineEvents) {
            this.ClientEvents = map.PolylineEvents.ClientEvents;
            this.ServerEvents = map.PolylineEvents.ServerEvents;
        }
        this.attachEvents(this.ClientEvents, true);
        this.attachEvents(this.ServerEvents, false);
    },

    attachEvents: function Artem$Web$GooglePolyline$attachEvents(events, clients) {
        if (events) {
            var key = events[i].Key;
            for (var i = 0; i < events.length; i++) {
                if (clients) {
                    GEvent.addListener(this.GPolyline, key,
                        Function.Delegate.createFromString(this, events[i].Handler));
                }
                else {
                    var handler = events[i].Handler;
                    var delegate = Function.Delegate.create(this, this.raiseEvent);
                    GEvent.addListener(this.GPolyline, key, function(args) {
                        delegate.call(this, handler, args);
                    });
                }
            }
        }
    },

    raiseEvent: function Artem$Web$GooglePolyline$raiseEvent(handler, args) {
        this.Map.save();
        if (handler) {
            handler = handler.replace("INDEX", this.Index);
            if (args)
                handler = handler.replace("ARGS", args);
            eval(handler);
        }
    },

    save: function Artem$Web$GooglePolyline$save() {
        var state = "{";
        //
        state += "\"Clickable\":" + this.Clickable + ",";
        state += "\"Color\":\"" + this.Color + "\",";
        state += "\"Geodesic\":" + this.Geodesic + ",";
        state += "\"Opacity\":" + this.Opacity + ",";
        state += "\"Weight\":" + this.Weight + ",";
        // points
        if (this.Points) {
            state += "\"Points\":[";
            var point;
            for (var i = 0; i < this.Points.length; i++) {
                point = this.Points[i];
                state += "{\"Latitude\":" + point.Latitude + ",\"Longitude\":" + point.Longitude + "},";
            }
            state = state.substr(0, state.length - 1);
            state += "],";
        }
        // bounds
        var bounds = new Artem.Web.GoogleBounds(this.getBounds());
        state += "\"Bounds\":";
        state += bounds.save();
        //
        state += "}";
        return state;
    },

    // Google Maps API Wrapped --------------------------------------------------------------------

    getBounds: function Artem$Web$GooglePolyline$getBounds() {
        return this.GPolyline.getBounds();
    },

    hide: function Artem$Web$GooglePolyline$hide() {
        this.GPolyline.hide();
    },

    isHidden: function Artem$Web$GooglePolyline$isHidden() {
        return this.GPolyline.isHidden();
    },

    show: function Artem$Web$GooglePolyline$show() {
        this.GPolyline.show();
    },

    supportsHide: function Artem$Web$GooglePolyline$supportsHide() {
        return this.GPolyline.supportsHide();
    },

    // Type ---------------------------------------------------------------------------------------
    __type: "Artem.Web.GooglePolyline"
};

// GoogleMarker class /////////////////////////////////////////////////////////////////////////////

Artem.Web.GoogleMarker = function Artem$Web$GoogleMarker(map, index, config) {
    this._init(map, index, config);
};

Artem.Web.GoogleMarker.prototype = {

    // Fields -------------------------------------------------------------------------------------

    GMarker: null,
    Map: null,
    Index: null,
    Address: null,
    AutoPan: null,
    Bouncy: null,
    Clickable: null,
    Draggable: null,
    DragCrossMove: null,
    IconAnchor: null,
    IconSize: null,
    IconUrl: null,
    InfoWindowAnchor: null,
    Latitude: null,
    Longitude: null,
    MaxZoom: null,
    MinZoom: null,
    OpenInfoBehaviour: null,
    OpenWindowContent: null,
    ShadowSize: null,
    ShadowUrl: null,
    Text: null,
    Title: null,

    ClientEvents: null,
    ServerEvents: null,

    // Methods ------------------------------------------------------------------------------------

    _init: function Artem$Web$GoogleMarker$_init(map, index, config) {

        this.Map = map;
        this.Index = index;

        this.Address = config.Address;
        this.AutoPan = config.AutoPan;
        this.Bouncy = config.Bouncy;
        this.Clickable = config.Clickable;
        this.Draggable = config.Draggable;
        this.DragCrossMove = config.DragCrossMove;
        this.IconAnchor = config.IconAnchor;
        this.IconSize = config.IconSize;
        this.IconUrl = config.IconUrl;
        this.InfoWindowAnchor = config.InfoWindowAnchor;
        this.Latitude = config.Latitude;
        this.Longitude = config.Longitude;
        this.MaxZoom = config.MaxZoom;
        this.MinZoom = config.MinZoom;
        this.OpenInfoBehaviour = config.OpenInfoBehaviour;
        this.ShadowSize = config.ShadowSize;
        this.ShadowUrl = config.ShadowUrl;
        this.Text = config.Text;
        this.Title = config.Title;

        // events
        if (map.MarkerEvents) {
            this.ClientEvents = map.MarkerEvents.ClientEvents;
            this.ServerEvents = map.MarkerEvents.ServerEvents;
        }
    },

    attachEvents: function Artem$Web$GoogleMarker$attachEvents(events, clients) {
        if (events) {
            for (var i = 0; i < events.length; i++) {
                var key = events[i].Key;
                if (clients) {
                    GEvent.addListener(this.GMarker, key,
                        Function.Delegate.createFromString(this, events[i].Handler));
                }
                else {
                    var handler = events[i].Handler;
                    var delegate = Function.Delegate.create(this, this.raiseEvent);
                    GEvent.addListener(this.GMarker, key, function(args) {
                        delegate.call(this, handler, args);
                    });
                }
            }
        }
    },

    initialize: function Artem$Web$GoogleMarker$initialize() {
        // open info behaviour
        var eventName;
        switch (this.OpenInfoBehaviour) {
            case Artem.Web.OpenInfoBehaviour.Click:
                eventName = "click";
                break;
            case Artem.Web.OpenInfoBehaviour.DoubleClick:
                eventName = "dblclick";
                break;
            case Artem.Web.OpenInfoBehaviour.MouseDown:
                eventName = "mousedown";
                break;
            case Artem.Web.OpenInfoBehaviour.MouseOut:
                eventName = "mouseout";
                break;
            case Artem.Web.OpenInfoBehaviour.MouseOver:
                eventName = "mouseover";
                break;
            case Artem.Web.OpenInfoBehaviour.MouseUp:
                eventName = "mouseup";
                break;
        }
        if (eventName)
            GEvent.addListener(this.GMarker, eventName, Function.Delegate.create(this, this.openDefaultInfoWindow));
        //events
        this.attachEvents(this.ClientEvents, true);
        this.attachEvents(this.ServerEvents, false);
    },

    isLoaded: function Artem$Web$GoogleMarker$isLoaded() {
        return (this.GMarker != null);
        //        if (this.GMarker == null) throw "Cannot use it before marker been loaded!";
    },

    load: function Artem$Web$GoogleMarker$load(point) {
        if (point) {
            // persist point
            this.Latitude = point.lat();
            this.Longitude = point.lng();
            // options
            var options = new Object();
            options.autoPan = this.AutoPan;
            options.bouncy = this.Bouncy;
            options.clickable = this.Clickable;
            options.draggable = this.Draggable;
            options.dragCrossMove = this.DragCrossMove;
            options.title = this.Title;
            options.icon = this.createIcon();
            // create
            this.GMarker = new GMarker(point, options);
            this.Map.addOverlay(this.GMarker);
            this.initialize();
        }
    },

    raiseEvent: function Artem$Web$GoogleMarker$raiseEvent(handler, args) {
        this.Map.save();
        if (handler) {
            handler = handler.replace("INDEX", this.Index);
            if (args)
                handler = handler.replace("ARGS", args);
            eval(handler);
        }
    },

    save: function Artem$Web$GoogleMarker$save() {
        var state = "{";
        //
        state += "\"Address\":\"" + this.Address + "\",";
        state += "\"AutoPan\":" + this.AutoPan + ",";
        state += "\"Bouncy\":" + this.Bouncy + ",";
        state += "\"Clickable\":" + this.Clickable + ",";
        state += "\"Draggable\":" + this.Draggable + ",";
        state += "\"DragCrossMove\":" + this.DragCrossMove + ",";
        if (this.IconAnchor)
            state += "\"IconAnchor\":{X:" + this.IconAnchor.X + ",Y:" + this.IconAnchor.Y + "},";
        if (this.IconSize)
            state += "\"IconSize\":{Width:" + this.IconSize.Width + ",Height:" + this.IconSize.Height + "},";
        state += "\"IconUrl\":\"" + this.IconUrl + "\",";
        if (this.InfoWindowAnchor)
            state += "\"InfoWindowAnchor\":{X:" + this.InfoWindowAnchor.X + ",Y:" + this.InfoWindowAnchor.Y + "},";
        var point = this.getLatLng();
        if (point) {
            state += "\"Latitude\":" + point.lat() + ",";
            state += "\"Longitude\":" + point.lng() + ",";
        }
        else {
            state += "\"Latitude\":" + this.Latitude + ",";
            state += "\"Longitude\":" + this.Longitude + ",";
        }
        state += "\"OpenInfoBehaviour\":" + this.OpenInfoBehaviour + ",";
        if (this.ShadowSize)
            state += "\"ShadowSize\":{Width:" + this.ShadowSize.Width + ",Height:" + this.ShadowSize.Height + "},";
        state += "\"ShadowUrl\":\"" + this.ShadowUrl + "\",";
        /*
        * >> FIX:   removed from post back in order to solve the issues with page ValidateRequest
        *           http://googlemap.codeplex.com/WorkItem/View.aspx?WorkItemId=7470
        */
        //        state += "\"Text\":\"" + this.Text + "\",";
        /*
        * << FIX
        */
        state += "\"Title\":\"" + this.Title + "\",";
        //
        state += "}";
        return state;
    },

    // Google Maps API Wrapped --------------------------------------------------------------------

    closeInfoWindow: function Artem$Web$GoogleMarker$closeInfoWindow() {
        if (this.isLoaded())
            this.GMarker.closeInfoWindow();
    },

    createIcon: function Artem$Web$GoogleMarker$createIcon() {
        var icon = null;
        if (this.IconUrl) {
            icon = new GIcon();
            icon.image = this.IconUrl;
            if (this.IconSize)
                icon.iconSize = new GSize(this.IconSize.Width, this.IconSize.Height);
            if (this.IconAnchor)
                icon.iconAnchor = new GPoint(this.IconAnchor.X, this.IconAnchor.Y);
            if (this.InfoWindowAnchor)
                icon.infoWindowAnchor = new GPoint(this.InfoWindowAnchor.X, this.InfoWindowAnchor.Y);
            if (this.ShadowUrl)
                icon.shadow = this.ShadowUrl;
            if (this.ShadowSize)
                icon.shadowSize = new GSize(this.ShadowSize.Width, this.ShadowSize.Height);
        }
        return icon;
    },

    disableDragging: function Artem$Web$GoogleMarker$disableDragging() {
        if (this.isLoaded())
            this.GMarker.disableDragging();
    },

    draggable: function Artem$Web$GoogleMarker$draggable() {
        if (this.isLoaded())
            return this.GMarker.draggable();
    },

    draggingEnabled: function Artem$Web$GoogleMarker$draggingEnabled() {
        if (this.isLoaded())
            return this.GMarker.draggingEnabled();
    },

    enableDragging: function Artem$Web$GoogleMarker$enableDragging() {
        if (this.isLoaded())
            this.GMarker.enableDragging();
    },

    getIcon: function Artem$Web$GoogleMarker$getIcon() {
        if (this.isLoaded())
            return this.GMarker.getIcon();
    },

    getLatLng: function Artem$Web$GoogleMarker$getLatLng() {
        if (this.isLoaded())
            return this.GMarker.getLatLng();
    },

    getPoint: function Artem$Web$GoogleMarker$getPoint() {
        if (this.isLoaded())
            return this.GMarker.getPoint();
    },

    getTitle: function Artem$Web$GoogleMarker$getTitle() {
        if (this.isLoaded())
            return this.GMarker.getTitle();
    },

    hide: function Artem$Web$GoogleMarker$hide() {
        if (this.isLoaded())
            this.GMarker.hide();
    },

    isHidden: function Artem$Web$GoogleMarker$isHidden() {
        if (this.isLoaded())
            return this.GMarker.isHidden();
    },

    openDefaultInfoWindow: function Artem$Web$GoogleMarker$openDefaultInfoWindow() {
        if (this.isLoaded()) {
            if (this.OpenWindowContent) {
                var node = document.getElementById(this.OpenWindowContent);
                this.openInfoWindow(node.cloneNode(true));
            }
            else
                this.openInfoWindowHtml(this.Text);
        }
    },

    openInfoWindow: function Artem$Web$GoogleMarker$openInfoWindow(domnode) {
        if (this.isLoaded())
            this.GMarker.openInfoWindow(domnode);
    },

    openInfoWindowHtml: function Artem$Web$GoogleMarker$openInfoWindowHtml(content) {
        if (this.isLoaded())
            this.GMarker.openInfoWindowHtml(content);
    },

    setImage: function Artem$Web$GoogleMarker$setImage(url) {
        if (this.isLoaded())
            this.GMarker.setImage(url);
    },

    setLatLng: function Artem$Web$GoogleMarker$setLatLng(point) {
        if (this.isLoaded())
            this.GMarker.setLatLng(point);
    },

    setPoint: function Artem$Web$GoogleMarker$setPoint(point) {
        if (this.isLoaded())
            this.GMarker.setPoint(point);
    },

    show: function Artem$Web$GoogleMarker$show() {
        if (this.isLoaded())
            this.GMarker.show();
    },

    // Type ---------------------------------------------------------------------------------------
    __type: "Artem.Web.GoogleMarker"
};

// GoogleMap class ////////////////////////////////////////////////////////////////////////////////

Artem.Web.GoogleMap = function Artem$Web$GoogleMap(config) {
    this._init(config);
};

Artem.Web.GoogleMap.prototype = {

    // Fields -------------------------------------------------------------------------------------

    Address: null,
    AddressNotFound: false,
    BaseCountryCode: null,
    DefaultAddress: null,
    DefaultMapView: null,
    ClientID: null,
    ClientMapID: null,
    IsGeolocation: false,
    IsStatic: null,
    IsStreetView: null,
    EnterpriseKey: null,
    Key: null,
    Latitude: null,
    Longitude: null,
    MarkerManagerOptions: null,
    ShowMapTypeControl: null,
    ShowScaleControl: null,
    ShowTraffic: null,
    StreetViewMode: null,
    StreetViewPanoID: null,
    Zoom: null,
    ZoomPanType: null,
    // behaviour
    EnableContinuousZoom: null,
    EnableDoubleClickZoom: null,
    EnableDragging: null,
    EnableGoogleBar: null,
    EnableInfoWindow: null,
    EnableMarkerManager: null,
    EnableReverseGeocoding: null,
    EnableScrollWheelZoom: null,
    // loaded
    IsLoaded: false,
    // events
    ClientEvents: null,
    ServerEvents: null,
    MarkerEvents: null,
    PolygonEvents: null,
    PolylineEvents: null,
    ClentAddressNotFoundIndex: null,
    ServerAddressNotFoundIndex: null,
    ClientGeoLoadedIndex: null,
    ServerGeoLoadedIndex: null,
    ClientLocationLoadedIndex: null,
    ServerLocationLoadedIndex: null,
    // collections
    Actions: null,
    Directions: null,
    Markers: [],
    Polygons: null,
    Polylines: null,
    // origin
    GMap: null,
    GMapPano: null,
    MarkerManager: null,
    // geocoder
    Geocoder: null,

    // Private Methods ----------------------------------------------------------------------------

    _init: function Artem$Web$GoogleMap$_init(config) {
        // properties
        this.Address = config.Address;
        this.BaseCountryCode = config.BaseCountryCode;
        this.DefaultAddress = config.DefaultAddress;
        this.DefaultMapView = config.DefaultMapView;
        this.ClientID = config.ClientID;
        this.ClientMapID = config.ClientMapID;
        this.IsStatic = config.IsStatic;
        this.IsStreetView = config.IsStreetView;
        this.EnterpriseKey = config.EnterpriseKey;
        this.Key = config.Key;
        this.Latitude = config.Latitude;
        this.Longitude = config.Longitude;
        this.MarkerManagerOptions = config.MarkerManagerOptions;
        this.ShowMapTypeControl = config.ShowMapTypeControl;
        this.ShowScaleControl = config.ShowScaleControl;
        this.ShowTraffic = config.ShowTraffic;
        this.StreetViewMode = config.StreetViewMode;
        this.StreetViewPanoID = config.StreetViewPanoID;
        this.Zoom = config.Zoom;
        this.ZoomPanType = config.ZoomPanType;
        // behaviour
        this.EnableContinuousZoom = config.EnableContinuousZoom;
        this.EnableDoubleClickZoom = config.EnableDoubleClickZoom;
        this.EnableDragging = config.EnableDragging;
        this.EnableGoogleBar = config.EnableGoogleBar;
        this.EnableInfoWindow = config.EnableInfoWindow;
        this.EnableMarkerManager = config.EnableMarkerManager;
        this.EnableReverseGeocoding = config.EnableReverseGeocoding;
        this.EnableScrollWheelZoom = config.EnableScrollWheelZoom;
        // events
        if (config.MapEvents) {
            this.ClientEvents = config.MapEvents.ClientEvents;
            this.ServerEvents = config.MapEvents.ServerEvents;
        }
        this.MarkerEvents = config.MarkerEvents;
        this.PolygonEvents = config.PolygonEvents;
        this.PolylineEvents = config.PolylineEvents;
        // geocoder
        this.Geocoder = new GClientGeocoder();
        if (config.BaseCountryCode)
            this.Geocoder.setBaseCountryCode(config.BaseCountryCode);
        // initialize manager
        Artem.Web.GoogleManager.initialize();
        Artem.Web.GoogleManager.addMap(this);
        // initialize
        if (!this.IsStatic && !(this.IsStreetView && this.StreetViewMode == 0)) {
            var options;
            if (this.Width && this.Height)
                options = { size: new GSize(this.Width, this.Height) };
            this.GMap = new GMap2(this.getElement(), options);
            //events
            this.attachEvents(this.ClientEvents, true);
            this.attachEvents(this.ServerEvents, false);
        }
    },

    _renderMarkerManager: function Artem$Web$GoogleMap$_renderMarkerManager() {
        if (this.EnableMarkerManager) {
            var marker;
            for (var i = 0; i < this.Markers.length; i++) {
                marker = this.Markers[i];
                this.MarkerManager.addMarker(marker.GMarker, marker.MinZoom, marker.MaxZoom);
            }
            this.MarkerManager.refresh();
        }
    },

    // Public Methods -----------------------------------------------------------------------------

    addAction: function Artem$Web$GoogleMap$addAction(action) {
        if (!this.Actions) this.Actions = new Array();
        this.Actions.push(action);
    },

    addDirection: function Artem$Web$GoogleMap$addDirection(config, render) {
        if (!this.Directions) this.Directions = new Array();
        var dir = new Artem.Web.GoogleDirection(this, config);
        this.Directions.push(dir);
        if (render) this.renderDirection(dir);
    },

    addMarker: function Artem$Web$GoogleMap$addMarker(config, render) {
        var marker = new Artem.Web.GoogleMarker(this, this.Markers.length, config);
        this.Markers.push(marker);
        if (render) this.renderMarker(marker);
    },

    addPolygon: function Artem$Web$GoogleMap$addPolygon(config, render) {
        if (!this.Polygons) this.Polygons = new Array();
        var polygon = new Artem.Web.GooglePolygon(this, this.Polygons.length, config);
        this.Polygons.push(polygon);
        if (render) this.renderPolygon(polygon);
    },

    addPolyline: function Artem$Web$GoogleMap$addPolyline(config, render) {
        if (!this.Polylines) this.Polylines = new Array();
        var polyline = new Artem.Web.GooglePolyline(this, this.Polylines.length, config);
        this.Polylines.push(polyline);
        if (render) this.renderPolyline(polyline);
    },

    attachEvents: function Artem$Web$GoogleMap$attachEvents(events, clients) {
        if (events) {
            var key;
            for (var i = 0; i < events.length; i++) {
                key = events[i].Key;
                if (key != 'geoload' && key != 'addressnotfound' && key != 'locationloaded') {
                    if (clients) {
                        GEvent.addListener(this.GMap, key,
                            Function.Delegate.createFromString(this, events[i].Handler));
                    }
                    else {
                        var handler = events[i].Handler;
                        var delegate = Function.Delegate.create(this, this.raiseEvent);
                        GEvent.addListener(this.GMap, key, function(overlay, args) {
                            delegate.call(this, handler, args);
                        });
                    }
                }
                else if (key == 'locationloaded') {
                    if (clients)
                        this.ClientLocationLoadedIndex = i;
                    else
                        this.ServerLocationLoadedIndex = i;
                }
                else if (key == 'addressnotfound') {
                    if (clients)
                        this.ClientAddressNotFoundIndex = i;
                    else
                        this.ServerAddressNotFoundIndex = i;
                }
                else {
                    if (clients)
                        this.ClientGeoLoadedIndex = i;
                    else
                        this.ServerGeoLoadedIndex = i;
                }
            }
        }
    },

    clearActions: function Artem$Web$GoogleMap$clearActions(action) {
        if (this.Actions) this.Actions = new Array();
    },

    clearDirections: function Artem$Web$GoogleMap$clearDirections(config) {
        if (this.Directions) this.Directions = new Array();
    },

    clearMarkers: function Artem$Web$GoogleMap$clearMarkers() {
        if (this.Markers) {
            var len = this.Markers.length;
            for (var i = 0; i < len; i++) {
                this.GMap.removeOverlay(this.Markers[i].GMarker);
            }
            this.Markers = new Array();
        }
    },

    clearPolygons: function Artem$Web$GoogleMap$clearPolygons(config) {
        if (this.Polygons) this.Polygons = new Array();
    },

    clearPolylines: function Artem$Web$GoogleMap$clearPolylines(config) {
        if (this.Polylines) this.Polylines = new Array();
    },

    getElement: function Artem$Web$GoogleMap$getElement() {
        return document.getElementById(this.ClientID);
    },

    initialize: function Artem$Web$GoogleMap$initialize() {
        // behaviour
        (this.EnableContinuousZoom) ? this.enableContinuousZoom() : this.disableContinuousZoom();
        (this.EnableDoubleClickZoom) ? this.enableDoubleClickZoom() : this.disableDoubleClickZoom();
        (this.EnableDragging) ? this.enableDragging() : this.disableDragging();
        (this.EnableGoogleBar) ? this.enableGoogleBar() : this.disableGoogleBar();
        (this.EnableInfoWindow) ? this.enableInfoWindow() : this.disableInfoWindow();
        (this.EnableScrollWheelZoom) ? this.enableScrollWheelZoom() : this.disableScrollWheelZoom();
        // controls
        switch (this.ZoomPanType) {
            case 1:
                this.GMap.addControl(new GLargeMapControl());
                break;
            case 2:
                this.GMap.addControl(new GSmallZoomControl());
                break;
            case 3:
                this.GMap.addControl(new GSmallZoomControl3D());
                break;
            case 4:
                this.GMap.addControl(new GLargeMapControl3D());
                break;
            default:
                this.GMap.addControl(new GSmallMapControl());
                break;
        }
        if (this.ShowMapTypeControl) this.GMap.addControl(new GMapTypeControl());
        if (this.ShowScaleControl) this.GMap.addControl(new GScaleControl());
        if (this.ShowTraffic) this.GMap.addOverlay(new GTrafficOverlay());
        // enable marker manager
        if (this.EnableMarkerManager) this.MarkerManager = new MarkerManager(this.GMap, this.MarkerManagerOptions);
        //        //events
        //        this.attachEvents(this.ClientEvents, true);
        //        this.attachEvents(this.ServerEvents, false);
        // map view
        this.setMapView();
        // street view
        if (this.IsStreetView && this.StreetViewMode == 1) {
            var panoID = this.StreetViewPanoID || (this.ClientID + "_Pano");
            this.GMapPano = new GStreetviewPanorama(document.getElementById(panoID));
            this.GMap.addOverlay(new GStreetviewOverlay());
            GEvent.addListener(this.GMap, "click", Function.Delegate.create(this, this.setStreetView));
            //            function(overlay, latlng) {
            //                pano.setLocationAndPOV(latlng);
            //            });
        }
    },

    load: function Artem$Web$GoogleMap$load(point) {
        if (point) {
            if (!this.IsStatic && !(this.IsStreetView && this.StreetViewMode == 0)) {
                this.Latitude = point.lat();
                this.Longitude = point.lng();
                this.setCenter(point, this.Zoom);
                if (this.IsGeolocation) {
                    this.IsGeolocation = false;
                    if (this.ClientGeoLoadedIndex != null)
                        Function.Delegate.callFromString(this, this.ClientEvents[this.ClientGeoLoadedIndex].Handler);
                    if (this.ServerGeoLoadedIndex != null) {
                        var handler = this.ServerEvents[this.ServerGeoLoadedIndex].Handler;
                        handler = handler.replace("ARGS", this.Address);
                        Function.Delegate.callFromString(this, handler);
                    }
                }
                if (this.EnableReverseGeocoding && !this.Address) {
                    var delegate = Function.Delegate.create(this, this.setAddress);
                    this.Geocoder.getLocations(point, delegate);
                }
                this.initialize();
                this.render();
                this.checkResize();
            }
            else if (this.IsStreetView) {
                this.loadStreetView(point);
            }
            else {
                this.loadStatic();
            }
            this.IsLoaded = true;
        }
        else {
            if ((this.Latitude != 0) && (this.Longitude != 0))
                this.load(new GLatLng(this.Latitude, this.Longitude));
            else {
                if (!this.IsGeolocation) {
                    this.IsGeolocation = true;
                    this.Geocoder.getLatLng(this.Address, Function.Delegate.create(this, this.load));
                }
                else if (!this.AddressNotFound) {
                    if (this.ClientAddressNotFoundIndex != null)
                        Function.Delegate.callFromString(this, this.ClientEvents[this.ClientAddressNotFoundIndex].Handler);
                    if (this.ServerAddressNotFoundIndex != null) {
                        var handler = this.ServerEvents[this.ServerAddressNotFoundIndex].Handler;
                        handler = handler.replace("ARGS", this.Address);
                        Function.Delegate.callFromString(this, handler);
                    }
                    this.AddressNotFound = true;
                    if (this.DefaultAddress) {
                        this.Address = this.DefaultAddress;
                        this.Geocoder.getLatLng(this.Address, Function.Delegate.create(this, this.load));
                    }
                }
            }
        }
    },

    loadAddress: function Artem$Web$GoogleMap$loadAddress(address) {
        this.Address = address;
        this.IsGeolocation = true;
        this.Geocoder.getLatLng(this.Address, Function.Delegate.create(this, this.load));
    },

    loadStatic: function Artem$Web$GoogleMap$loadStatic() {
        var el = this.getElement();
        //
        var width = 512;
        if (this.Didth && this.Width < 512) width = this.Width;
        var height = 512;
        if (this.Height && this.Height < 512) height = this.Height;
        //
        var src = "http:\/\/maps.google.com\/staticmap?";
        src += "center=" + this.Latitude + "," + this.Longitude + "&";
        src += "zoom=" + this.Zoom + "&";
        src += "size=" + width + "x" + height + "&";
        if (this.EnterpriseKey)
            src += "enterpriseKey=" + this.EnterpriseKey + "&";
        src += "key=" + this.Key;
        // markers
        if (this.Markers) {
            var i;
            src += "&markers=";
            for (i = 0; i < this.Markers.length; i++)
                src += this.Markers[i].Latitude + "," + this.Markers[i].Longitude + "|";
        }
        // 
        var img = document.createElement("img");
        img.src = src;
        el.appendChild(img);
    },

    loadStreetView: function Artem$Web$GoogleMap$loadStreetView(point) {
        this.GMap = new GStreetviewPanorama(this.getElement(), { latlng: point });
        this.GMap.checkResize();
        //        GEvent.addListener(this.GMapPano, "error", function() {
        //            if (errorCode == 603) {
        //                alert("Error: Flash doesn't appear to be supported by your browser");
        //                return;
        //            }
        //        });
    },

    raiseEvent: function Artem$Web$GoogleMap$raiseEvent(handler, args) {
        if (this.IsLoaded) {
            this.save();
            if (handler) {
                if (args)
                    handler = handler.replace("ARGS", args);
                eval(handler);
            }
        }
    },

    render: function Artem$Web$GoogleMap$render() {
        // markers
        if (this.Markers) {
            var loader = new Artem.Web.Geoloader(this.Geocoder,
                                Function.Delegate.create(this, this._renderMarkerManager));
            for (var i = 0; i < this.Markers.length; i++) {
                if (!this.renderMarker(this.Markers[i]))
                    loader.addMarker(this.Markers[i]);
            }
            loader.load();
        }
        // directions
        if (this.Directions) {
            for (var i = 0; i < this.Directions.length; i++) {
                this.renderDirection(this.Directions[i]);
            }
        }
        // polylines
        if (this.Polylines) {
            for (var i = 0; i < this.Polylines.length; i++) {
                this.renderPolyline(this.Polylines[i]);
            }
        }
        // polygons
        if (this.Polygons) {
            for (var i = 0; i < this.Polygons.length; i++) {
                this.renderPolygon(this.Polygons[i]);
            }
        }
        // fire actions
        if (this.Actions) {
            for (var i = 0; i < this.Actions.length; i++) {
                Function.Delegate.callFromString(this, this.Actions[i]);
            }
        }
    },

    renderDirection: function Artem$Web$GoogleMap$renderDirection(d) {
        d.loadDefault();
    },

    renderMarker: function Artem$Web$GoogleMap$renderMarker(m) {
        if ((m.Latitude != 0) && (m.Longitude != 0)) {
            try {
                m.load(new GLatLng(m.Latitude, m.Longitude));
            }
            catch (ex) { }
            return true;
        }
        else {
            return false;
        }
    },

    renderPolygon: function Artem$Web$GoogleMap$renderPolygon(pg) {
        this.addOverlay(pg.GPolygon);
    },

    renderPolyline: function Artem$Web$GoogleMap$renderPolyline(pl) {
        this.addOverlay(pl.GPolyline);
    },

    save: function Artem$Web$GoogleMap$save() {
        var state = "{";
        state += "\"Address\":\"" + this.Address + "\"";
        state += ",\"BaseCountryCode\":\"" + this.BaseCountryCode + "\"";
        state += ",\"DefaultMapView\":" + Artem.Web.GoogleMapView.convert(this.getCurrentMapType()); // this.DefaultMapView;
        state += ",\"EnableGoogleBar\":" + this.EnableGoogleBar;
        state += ",\"EnableMarkerManager\":" + this.EnableMarkerManager;
        state += ",\"EnableScrollWheelZoom\":" + this.EnableScrollWheelZoom;
        state += ",\"IsStatic\":" + this.IsStatic;
        var center = this.getCenter();
        if (center) {
            state += ",\"Latitude\":" + center.lat();
            state += ",\"Longitude\":" + center.lng();
        }
        else {
            state += ",\"Latitude\":" + this.Latitude;
            state += ",\"Longitude\":" + this.Longitude;
        }
        state += ",\"ShowMapTypeControl\":" + this.ShowMapTypeControl;
        state += ",\"ShowTraffic\":" + this.ShowTraffic;
        state += ",\"Zoom\":" + this.getZoom(); //this.Zoom;
        state += ",\"ZoomPanType\":" + this.ZoomPanType;
        // bounds
        var bounds = new Artem.Web.GoogleBounds(this.getBounds());
        state += ",\"Bounds\":";
        state += bounds.save();
        // markers
        if (this.Markers) {
            state += ",\"Markers\":[";
            for (var i = 0; i < this.Markers.length; i++) {
                if (this.Markers[i].isLoaded())
                    state += this.Markers[i].save();
            }
            state += "]";
        }
        // directions
        if (this.Directions) {
            state += ",\"Directions\":[";
            for (var i = 0; i < this.Directions.length; i++) {
                state += this.Directions[i].save();
            }
            state += "]";
        }
        // polylines
        if (this.Polylines) {
            state += ",\"Polylines\":[";
            for (var i = 0; i < this.Polylines.length; i++) {
                state += this.Polylines[i].save();
            }
            state += "]";
        }
        // polygons
        if (this.Polygons) {
            state += ",\"Polygons\":[";
            for (var i = 0; i < this.Polygons.length; i++) {
                state += this.Polygons[i].save();
            }
            state += "]";
        }
        //
        state += "}";
        var bag = document.getElementById(this.ClientID + "_State");
        bag.value = state;
    },

    setAddress: function Artem$Web$GoogleMap$setAddress(addresses) {
        if (addresses.Status.code == 200) {
            try {
                this.Address = addresses.Placemark[0].address;
                this.save();
                if (this.ClientLocationLoadedIndex != null) {
                    var delegate = Function.Delegate.createFromString(this, this.ClientEvents[this.ClientLocationLoadedIndex].Handler);
                    delegate.call(this, this.Address);
                }
                if (this.ServerLocationLoadedIndex != null) {
                    var handler = this.ServerEvents[this.ServerLocationLoadedIndex].Handler;
                    handler = handler.replace("ARGS", this.Address);
                    Function.Delegate.callFromString(this, handler);
                }
            }
            catch (ex) { }
        }
    },

    setMapView: function Artem$Web$GoogleMap$setMapView() {
        // set view
        if (this.DefaultMapView) {
            switch (this.DefaultMapView) {
                case Artem.Web.GoogleMapView.Normal:
                    this.GMap.setMapType(G_NORMAL_MAP);
                    break;
                case Artem.Web.GoogleMapView.Satellite:
                    this.GMap.setMapType(G_SATELLITE_MAP);
                    break;
                case Artem.Web.GoogleMapView.Hybrid:
                    this.GMap.setMapType(G_HYBRID_MAP);
                    break;
                case Artem.Web.GoogleMapView.Physical:
                    this.GMap.addMapType(G_PHYSICAL_MAP);
                    this.GMap.setMapType(G_PHYSICAL_MAP);
                    break;
                case Artem.Web.GoogleMapView.MoonElevation:
                    this.GMap.addMapType(G_MOON_ELEVATION_MAP);
                    this.GMap.setMapType(G_MOON_ELEVATION_MAP);
                    break;
                case Artem.Web.GoogleMapView.MoonVisible:
                    this.GMap.addMapType(G_MOON_VISIBLE_MAP);
                    this.GMap.setMapType(G_MOON_VISIBLE_MAP);
                    break;
                case Artem.Web.GoogleMapView.MarsElevation:
                    this.GMap.addMapType(G_MARS_ELEVATION_MAP);
                    this.GMap.setMapType(G_MARS_ELEVATION_MAP);
                    break;
                case Artem.Web.GoogleMapView.MarsVisible:
                    this.GMap.addMapType(G_MARS_VISIBLE_MAP);
                    this.GMap.setMapType(G_MARS_VISIBLE_MAP);
                    break;
                case Artem.Web.GoogleMapView.MarsInfrared:
                    this.GMap.addMapType(G_MARS_INFRARED_MAP);
                    this.GMap.setMapType(G_MARS_INFRARED_MAP);
                    break;
                case Artem.Web.GoogleMapView.SkyVisible:
                    this.GMap.addMapType(G_SKY_VISIBLE_MAP);
                    this.GMap.setMapType(G_SKY_VISIBLE_MAP);
                    break;
                case Artem.Web.GoogleMapView.Satellite3D:
                    this.GMap.addMapType(G_SATELLITE_3D_MAP);
                    this.GMap.setMapType(G_SATELLITE_3D_MAP);
                    break;
                case Artem.Web.GoogleMapView.MapMakerNormal:
                    this.GMap.addMapType(G_MAPMAKER_NORMAL_MAP);
                    this.GMap.setMapType(G_MAPMAKER_NORMAL_MAP);
                    break;
                case Artem.Web.GoogleMapView.MapMakerHybrid:
                    this.GMap.addMapType(G_MAPMAKER_HYBRID_MAP);
                    this.GMap.setMapType(G_MAPMAKER_HYBRID_MAP);
                    break;
            }
        }
    },

    setStreetView: function Artem$Web$GoogleMap$setStreetView(overlay, latlng) {
        this.GMapPano.setLocationAndPOV(latlng);
    },

    // Google Maps API Wrapped --------------------------------------------------------------------

    addControl: function Artem$Web$GoogleMap$addControl(control, position) {
        this.GMap.addControl(control, position);
    },

    addMapType: function Artem$Web$GoogleMap$addMapType(type) {
        this.GMap.addMapType(type);
    },

    addOverlay: function Artem$Web$GoogleMap$addOverlay(overlay) {
        this.GMap.addOverlay(overlay);
    },

    checkResize: function Artem$Web$GoogleMap$checkResize() {
        this.GMap.checkResize();
    },

    clearOverlays: function Artem$Web$GoogleMap$clearOverlays() {
        this.GMap.clearOverlays();
    },

    closeInfoWindow: function Artem$Web$GoogleMap$closeInfoWindow() {
        this.GMap.closeInfoWindow();
    },

    continuousZoomEnabled: function Artem$Web$GoogleMap$continuousZoomEnabled() {
        return this.GMap.continuousZoomEnabled();
    },

    disableContinuousZoom: function Artem$Web$GoogleMap$disableContinuousZoom() {
        this.GMap.disableContinuousZoom();
    },

    disableDoubleClickZoom: function Artem$Web$GoogleMap$disableDoubleClickZoom() {
        this.GMap.disableDoubleClickZoom();
    },

    disableDragging: function Artem$Web$GoogleMap$disableDragging() {
        this.GMap.disableDragging();
    },

    disableGoogleBar: function Artem$Web$GoogleMap$disableGoogleBar() {
        this.GMap.disableGoogleBar();
    },

    disableInfoWindow: function Artem$Web$GoogleMap$disableInfoWindow() {
        this.GMap.disableInfoWindow();
    },

    disableScrollWheelZoom: function Artem$Web$GoogleMap$disableScrollWheelZoom() {
        this.GMap.disableScrollWheelZoom();
    },

    doubleClickZoomEnabled: function Artem$Web$GoogleMap$doubleClickZoomEnabled() {
        return this.GMap.doubleClickZoomEnabled();
    },

    draggingEnabled: function Artem$Web$GoogleMap$draggingEnabled() {
        return this.GMap.draggingEnabled();
    },

    enableContinuousZoom: function Artem$Web$GoogleMap$enableContinuousZoom() {
        this.GMap.enableContinuousZoom();
    },

    enableDoubleClickZoom: function Artem$Web$GoogleMap$enableDoubleClickZoom() {
        this.GMap.enableDoubleClickZoom();
    },

    enableDragging: function Artem$Web$GoogleMap$enableDragging() {
        this.GMap.enableDragging();
    },

    enableGoogleBar: function Artem$Web$GoogleMap$enableGoogleBar() {
        this.GMap.enableGoogleBar();
    },

    enableInfoWindow: function Artem$Web$GoogleMap$enableInfoWindow() {
        this.GMap.enableInfoWindow();
    },

    enableScrollWheelZoom: function Artem$Web$GoogleMap$enableScrollWheelZoom() {
        this.GMap.enableScrollWheelZoom();
    },

    fromContainerPixelToLatLng: function Artem$Web$GoogleMap$fromContainerPixelToLatLng(pixel) {
        return this.GMap.fromContainerPixelToLatLng(pixel);
    },

    fromDivPixelToLatLng: function Artem$Web$GoogleMap$fromDivPixelToLatLng(pixel) {
        return this.GMap.fromDivPixelToLatLng(pixel);
    },

    fromLatLngToDivPixel: function Artem$Web$GoogleMap$fromLatLngToDivPixel(latlng) {
        return this.GMap.fromLatLngToDivPixel(latlng);
    },

    getBounds: function Artem$Web$GoogleMap$getBounds() {
        return this.GMap.getBounds();
    },

    getBoundsZoomLevel: function Artem$Web$GoogleMap$getBoundsZoomLevel() {
        return this.GMap.getBoundsZoomLevel();
    },

    getCenter: function Artem$Web$GoogleMap$getCenter() {
        return this.GMap.getCenter();
    },

    getContainer: function Artem$Web$GoogleMap$getContainer() {
        return this.GMap.getContainer();
    },

    getCurrentMapType: function Artem$Web$GoogleMap$getCurrentMapType() {
        return this.GMap.getCurrentMapType();
    },

    getDragObject: function Artem$Web$GoogleMap$getDragObject() {
        return this.GMap.getDragObject();
    },

    getInfoWindow: function Artem$Web$GoogleMap$getInfoWindow() {
        return this.GMap.getInfoWindow();
    },

    getMapTypes: function Artem$Web$GoogleMap$getMapTypes() {
        return this.GMap.getMapTypes();
    },

    getPane: function Artem$Web$GoogleMap$getPane(pane) {
        return this.GMap.getPane();
    },

    getSize: function Artem$Web$GoogleMap$getSize() {
        return this.GMap.getSize();
    },

    getZoom: function Artem$Web$GoogleMap$getZoom() {
        return this.GMap.getZoom();
    },

    infoWindowEnabled: function Artem$Web$GoogleMap$infoWindowEnabled() {
        return this.GMap.infoWindowEnabled();
    },

    isLoaded: function Artem$Web$GoogleMap$isLoaded() {
        return this.GMap.isLoaded();
    },

    openInfoWindow: function Artem$Web$GoogleMap$openInfoWindow(point, node, opts) {
        this.GMap.openInfoWindow(point, node, opts);
    },

    openInfoWindowHtml: function Artem$Web$GoogleMap$openInfoWindowHtml(point, html, opts) {
        this.GMap.openInfoWindowHtml(point, html, opts);
    },

    panBy: function Artem$Web$GoogleMap$panBy(distance) {
        this.GMap.panBy(distance);
    },

    panDirection: function Artem$Web$GoogleMap$panDirection(dx, dy) {
        this.GMap.panDirection(dx, dy);
    },

    panTo: function Artem$Web$GoogleMap$panTo(center) {
        this.GMap.panTo(center);
    },

    removeControl: function Artem$Web$GoogleMap$removeControl(control) {
        this.GMap.removeControl(control);
    },

    removeMapType: function Artem$Web$GoogleMap$removeMapType(type) {
        this.GMap.removeMapType();
    },

    removeOverlay: function Artem$Web$GoogleMap$removeOverlay(overlay) {
        this.GMap.removeOverlay(overlay);
    },

    returnToSavedPosition: function Artem$Web$GoogleMap$returnToSavedPosition() {
        this.GMap.returnToSavedPosition();
    },

    savePosition: function Artem$Web$GoogleMap$savePosition() {
        this.GMap.savePosition();
    },

    scrollWheelZoomEnabled: function Artem$Web$GoogleMap$scrollWheelZoomEnabled() {
        return this.GMap.scrollWheelZoomEnabled();
    },

    setCenter: function Artem$Web$GoogleMap$setCenter(point, zoom, type) {
        this.GMap.setCenter(point, zoom, type);
    },

    setMapType: function Artem$Web$GoogleMap$setMapType(type) {
        this.GMap.setMapType(type);
    },

    setZoom: function Artem$Web$GoogleMap$setZoom(level) {
        this.GMap.setZoom(level);
    },

    zoomIn: function Artem$Web$GoogleMap$zoomIn() {
        this.GMap.zoomIn();
    },

    zoomOut: function Artem$Web$GoogleMap$zoomOut() {
        this.GMap.zoomOut();
    },

    // Type ---------------------------------------------------------------------------------------
    __type: "Artem.Web.GoogleMap"
};

// Geoloader class ////////////////////////////////////////////////////////////////////////////////

Artem.Web.Geoloader = function Artem$Web$Geoloader(geocoder, callback) {
    this._init(geocoder, callback);
};

Artem.Web.Geoloader.prototype = {

    // Fields -------------------------------------------------------------------------------------

    _callback: null,
    _count: 0,
    _delegate: null,
    _geocoder: null,
    _index: 0,
    _markers: [],

    // Methods ------------------------------------------------------------------------------------

    _init: function Artem$Web$Geoloader$_init(geocoder, callback) {
        this._callback = callback;
        this._delegate = Function.Delegate.create(this, this.resolve);
        this._geocoder = geocoder;
    },

    addMarker: function Artem$Web$Geoloader$addMarker(marker) {
        this._markers.push(marker);
    },

    load: function Artem$Web$Geoloader$load() {
        if (this._markers.length > 0) {
            this._index = (this._markers.length - 1);
            var marker = this._markers[this._index];
            this._geocoder.getLatLng(marker.Address, this._delegate);
        }
        else if (this._callback) {
            this._callback();
        }
    },

    resolve: function Artem$Web$Geoloader$resolve(point) {
        if (point) {
            this._markers[this._index].load(point);
            this._index--;
            if (this._index >= 0) {
                this._count = 0;
                this._geocoder.getLatLng(this._markers[this._index].Address, this._delegate);
            }
            else if (this._callback) {
                this._callback();
            }
        }
        else {
            if (this._count < 6) {
                var delay = this._count * 100;
                this._count++;
                setTimeout(delay, function() { });
                this._geocoder.getLatLng(this._markers[this._index].Address, this._delegate);
            }
            else if ((this._index--) >= 0) {
                this._count = 0;
                this._geocoder.getLatLng(this._markers[this._index].Address, this._delegate);
            }
        }
    },

    // Type ---------------------------------------------------------------------------------------
    __type: "Artem.Web.Geoloader"
};


// Global /////////////////////////////////////////////////////////////////////////////////////////

Function.Handler = {
    cache: {}
};

if (typeof (Sys) == 'undefined') {

    Function.Delegate.create = function(instance, method) {
        return function() { return method.apply(instance, arguments); };
    };

    Function.Handler.add = function(element, eventName, handler) {
        var browserHandler;
        if (element.addEventListener) {
            browserHandler = function(e) {
                return handler.call(element, e);
            }
            element.addEventListener(eventName, browserHandler, false);
        }
        else if (element.attachEvent) {
            browserHandler = function() {
                var e = {};
                try { e = window.event; } catch (ex) { }
                return handler.call(element, e);
            }
            element.attachEvent('on' + eventName, browserHandler);
        }
        Function.Handler.cache[Function.Handler.cache.length] = { handler: handler, browserHandler: browserHandler };
    };

    Function.Handler.remove = function(element, eventName, handler) {
        var browserHandler = null;
        var cache = Function.Handler.cache;
        var i = 0;
        var l = cache.length;
        for (; i < l; i++) {
            if (cache[i].handler === handler) {
                browserHandler = cache[i].browserHandler;
                break;
            }
        }
        if (browserHandler) {
            if (element.removeEventListener) {
                element.removeEventListener(eventName, browserHandler, false);
            }
            else if (element.detachEvent) {
                element.detachEvent('on' + eventName, browserHandler);
            }
            cache.splice(i, 1);
        }
    };
}
else {
    Function.Delegate.create = Function.createDelegate;
    Function.Handler.add = $addHandler;
    Function.Handler.remove = $removeHandler;
}

// AJAX notify ////////////////////////////////////////////////////////////////////////////////////

if (typeof (Sys) !== 'undefined') Sys.Application.notifyScriptLoaded();