﻿define [
  'backbone'
  'backbone.marionette'
  'gridster'
  './widget_factory'
  './collections/widgets'
  './views/widget_item'
  './layout'
], (
  Backbone
  Marionette
  Gridster
  WidgetFactory
  Widgets
  WidgetItem
  template
) ->
  class EditorGrid extends Marionette.CompositeView
    template: template
    childView: WidgetItem
    childViewContainer: '.grid-layout'
    className: 'editor-grid gridster'

    initialize: ->
      @collection = new Widgets()
      super

    collectionEvents:
      'change': 'render'
    ui:
      grid: '.grid-layout'

    buildChildView: (item, ItemView) ->
      new ItemView
        model: item
        editor: this

    render: ->
      @collection.fetch().done =>

        @collection.create(WidgetFactory.getAttributesFor('menubar'))
#        @collection.create({
#          name: 'bar foo baz this is fun'
#          x: 4
#          y: 1
#          width: 3
#          height: 5
#          collapsed: false
#        })

        super

    calcGridsterSize: ->
      height = $(window).height() - 36
      width = $(window).width() - 36
      {
        cols: Math.floor width / 42
        rows: Math.floor height / 42
      }

    onShow: ->
      @gridSize = @calcGridsterSize()
      @ui.grid.css 'min-height': (@gridSize.rows * 42), 'min-width': (@gridSize.cols * 42)

      @ui.grid.gridster
        widget_selector: '.widget-wrapper'
        widget_base_dimensions: [42, 42]
        widget_margins: [0, 0]
        min_cols: @gridSize.cols
        min_rows: @gridSize.rows
        draggable:
          enabled: true
          handle: '.drag-handle'
          start: => @ui.grid.addClass('active')
          stop: =>
            @ui.grid.removeClass('active')
            @gridster.serialize()
        resize:
          enabled: true
          start: => @ui.grid.addClass('active')
          stop: =>
            @ui.grid.removeClass('active')
            @gridster.serialize()
        serialize_params: (elem, widget) =>
          elem.data('view')?.trigger 'gridster:change',
            x: widget.col
            y: widget.row
            width: widget.size_x
            height: widget.size_y
      @gridster = @ui.grid.data('gridster')
      console.log @gridster

    attachHtml: (collectionView, childView, index) ->
      super
      @gridster.add_widget(childView.$el) if @gridster?

    removeChildView: (childView) ->
      @gridster.remove_widget(childView.$el) if @gridster?
      super