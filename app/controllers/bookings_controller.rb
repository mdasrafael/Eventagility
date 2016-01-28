class BookingsController < ApplicationController
  before_action :authenticate_user!, except: [:notify]


  def preload
    space = Space.find(params[:space_id])
    today = Date.today
    bookings = space.bookings.where("start_date >= ? OR end_date >= ?", today, today)

    render json: bookings
  end

  def preview
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    output = {
      conflict: is_conflict(start_date, end_date)
    }

    render json: output
  end

  def create
=begin trying to check if user is the space owner, can't access the booked space id
    current_user.spaces.each do |space|
      #value: @space.id
      if space.id == booking_params.fifth
        redirect_to space, alert: "Your booking has failed..."
        return false
      end
    end
=end
    @booking = current_user.bookings.create(booking_params)

    if @booking
      #send request to Paypal
      values = {
        business: 'mdas.rafael-facilitator@gmail.com',
        cmd: '_xclick',
        upload: 1,
        notify_url: 'http://322c2da9.ngrok.io/notify',
        amount: @booking.total,
        item_name: @booking.space.space_name,
        item_number: @booking.id,
        quantity: '1',
        return: 'http://322c2da9.ngrok.io/your_events'
      }

      redirect_to "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query, notice: "Your booking has been registered..."
    else
      redirect_to @booking.space, alert: "Oops, something went wrong..."
    end
  end

  protect_from_forgery except: [:notify]
  def notify
    params.permit!
    status = params[:payment_status]

    booking = Booking.find(params[:item_number])

    if status = "Completed"
      booking.update_attributes status:true
    else
      booking.destroy
    end

    render nothing: true
  end

  def your_bookings
    @space = current_user.spaces
  end

  protect_from_forgery except: [:your_events]
  def your_events
    @events = current_user.bookings.where("status = ?", true)
  end

  private

    def is_conflict(start_date, end_date)
      space = Space.find(params[:space_id])

      check = space.bookings.where("? < start_date AND end_date < ?", start_date, end_date)
      check.size > 0? true : false
    end

    def booking_params
      params.require(:booking).permit(:start_date, :end_date, :price, :total, :space_id)
    end
end
