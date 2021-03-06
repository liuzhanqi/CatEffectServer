# Handler called when page is loaded
this.pageLoad ->
  this.getStall(setStall) # defined in stall/common.coffee

# The callback function of getStallId
setStall = (stall) ->
  this.stall = stall
  this.stallId = stall['stallId']
  if stall['image']
    $('body').css("background-image", "url('/assets/uploads/" + stall['image'] + "')")
  else
    $('body').css("background-image", 'url("/assets/images/order-background-dafault.jpg")')
  $('h1').html stall['name']
  loadData()

this.orderItemNextId = orderItemNextId = 1;
this.dishOrderedList = dishOrderedList = []
this.categories = categories = []

loadData = () ->
  # Ajax get memu
  $.ajax
    url:      "/public/categories/getAll/" + this.stallId
    type:     "get"
    dataType: "json"
    success:  (data) ->
      if (!data["error"])
        categories = data["categories"]
        loadMenu()

# Load data into web page
loadMenu = () ->
  categoryTemplate = _.template $("#category-template").html()
  $categoryList = $("#category-list")
  createObject = (category) ->
    categoryId = category["categoryId"]
    $categoryObject = $(categoryTemplate(category))
    $categoryList.append($categoryObject)

  for category in categories
    createObject(category)

this.findDish = findDish = (dishId) ->
  for category in categories
    for dish in category['dishes']
      if dish['dishId'] == dishId
        return dish

this.showDish = (dishId) ->
  $('.show-dish').remove()
  dishTemplate = _.template $("#dish-template").html()
  dish = findDish(dishId)
  $popBox = $("<div class='pop-box'></div>")
  $popBox.html dishTemplate(dish)
  $('body').append($popBox)

this.cancelDish = () ->
  $(".pop-box").remove()

this.orderDish = (dishId) ->
  orderItem =
    orderItemId:  orderItemNextId
    dishId:       dishId
    quantity:     parseInt($("#dish-" + dishId).find(".quantity").val())
    note:         $("#dish-" + dishId).find(".note").val()
  orderItemNextId++
  dishOrderedList.push(orderItem)
  $(".pop-box").remove()
  this.showDishOrdered()

this.showDishOrdered = () ->
  subtotal = 0
  for orderItem in dishOrderedList
    dish = findDish(orderItem['dishId'])
    subtotal += dish['finalPrice'] * orderItem['quantity']
  $(".current-subtotal").html displayMoney(subtotal)
  orderedDishTemplate = _.template $("#ordered-dish-template").html()
  $orderedList = $("#ordered-list")
  $orderedList.html ""
  createOrderedObject = (orderedDish) ->
    $orderedDishObject = $(orderedDishTemplate(orderedDish))
    $orderedList.append($orderedDishObject)

  if dishOrderedList.length == 0
    $("#ordered-list-placeholder").hide()
    $("#button-check-out").hide()
    $("#button-cancel-all").hide()
    $orderedList.hide(300)
  else
    $("#ordered-list-placeholder").show()
    $("#button-check-out").delay(300).show(300)
    $("#button-cancel-all").delay(300).show(300)
    $orderedList.show(300)

  for orderItem in dishOrderedList
    createOrderedObject(orderItem)

this.deleteOrderItem = (orderItemId) ->
  for orderItem, id in dishOrderedList
    if orderItem['orderItemId'] == orderItemId
      dishOrderedList.splice(id, 1)
      break
  this.showDishOrdered()

getOrderItems = ->
  orderItems = []
  for orderItem in dishOrderedList
    dish = findDish(orderItem['dishId'])
    orderItems.push
      dishId:     orderItem['dishId']
      quantity:   orderItem['quantity']
      note:       orderItem['note']
      price:      dish['finalPrice']
      listPrice:  dish['price']
  return orderItems

getCheckOutSummary = ->
  orderItems = getOrderItems()
  subtotal = 0
  for orderItem in dishOrderedList
    dish = findDish(orderItem['dishId'])
    subtotal += dish['finalPrice'] * orderItem['quantity']
  discount = 0
  if this.account.type == 0
    discount = this.stall.prepaidDiscount
  else if this.account.type == 1
    discount = this.stall.studentDiscount
  else if this.account.type == 2
    discount = this.stall.facultyDiscount
  else if this.account.type == 3
    discount = this.stall.staffDiscount
  postData =
    accountId:  this.account['accountId']
    stallId:    this.stallId
    original:   subtotal
    subtotal:   Math.floor(subtotal * (100 - discount) / 100)
    orderItems: JSON.stringify(orderItems)
  return postData

this.showCheckOut = ->
  getAccountInfo ->
    $("#check-out-summary").show(300)
    accountName = ""
    discount = 0
    if this.account.type == 0
      accountName = "Prepaid-Card User"
      discount = this.stall.prepaidDiscount
    else if this.account.type == 1
      accountName = "Student " + this.account['student']['name']
      discount = this.stall.studentDiscount
    else if this.account.type == 2
      accountName = "Faculty " + this.account['faculty']['name']
      discount = this.stall.facultyDiscount
    else if this.account.type == 3
      accountName = "Staff " + this.account['staff']['name']
      discount = this.stall.staffDiscount
    $(".account-name").html accountName
    $(".account-balance").html displayMoney(this.account['balance'])
    $("#check-out-dish-tbody").html("")
    orderItems = getOrderItems()
    rowTemplate = _.template $("#check-out-dish-template").html()
    for orderItem in orderItems
      $("#check-out-dish-tbody").append(rowTemplate(orderItem))
    original = getCheckOutSummary()['original']
    subtotal = getCheckOutSummary()['subtotal']
    $("#check-out-discount").html discount
    $("#check-out-original").html displayMoney(original)
    $("#check-out-subtotal").html displayMoney(subtotal)
    if subtotal > this.account['balance']
      $(".success-buttons").hide()
      $(".fail-buttons").show()
    else
      this.newBalance = this.account['balance'] - subtotal
      $(".success-buttons").show()
      $(".fail-buttons").hide()
    $("#check-out-summary").show(300)

this.checkOut = ->
  that = this
  postData = getCheckOutSummary()
  $.ajax
    url:      "/order/orders/add"
    type:     "post"
    dataType: "json"
    data:     postData
    success:  (data) ->
      $(".new-balance").html displayMoney(that.newBalance)
      if that.newBalance < 500
        $('.top-up-suggest').show()
      else
        $('.top-up-suggest').hide()
      $("#check-out-success").show();
      refresh = ->
        location.reload()
      setTimeout(refresh, 5000)


this.cancelOrder = ->
  $("#check-out-summary").hide(300)

getAccountString = ->
  if this.javaMode()
    accountString = this.java.getAccountString()
  else
    accountString = "2 U1220822F"
  if accountString == null
    accountString = ""
  return accountString

getAccountInfo = (callback) ->
  that = this
  accountString = getAccountString()
  $.ajax
    url: "/order/getAccountByString"
    type: "post"
    dataType: "json"
    data:
      accountString: accountString
    success: (data) ->
      if data['error'] == 0
        that.account = data['account']
        if that.account && that.account.hasOwnProperty("accountId")
          callback.call(that)

this.plus = ->
  org = parseInt($(".pop-box").find("input.quantity").val())
  org++
  $(".pop-box").find("input.quantity").val org


this.minus = ->
  org = parseInt($(".pop-box").find("input.quantity").val())
  org--
  if org < 1
    org = 1
  $(".pop-box").find("input.quantity").val org

this.setOption = (option, id) ->
  $(".pop-box").find("input.note").val option
  $(".pop-box").find(".option-button").removeClass("btn-primary").addClass("btn-default")
  $(".pop-box").find("#option-" + id).removeClass("btn-default").addClass("btn-primary")