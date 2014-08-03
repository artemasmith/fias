class RegionsController < ApplicationController
  def index
    parent = params[:parent].blank? ? Location.where('location_id > 0').first.location_id : params[:parent].to_i
    @region = Location.find(parent)
    @locations = Location.where(location_id: parent).paginate(per_page: 10, page: params[:page])
  end
end
