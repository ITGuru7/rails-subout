class RegionTypesController < ApplicationController
  # GET /region_types
  # GET /region_types.json
  def index
    @region_types = RegionType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @region_types }
    end
  end

  # GET /region_types/1
  # GET /region_types/1.json
  def show
    @region_type = RegionType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @region_type }
    end
  end

  # GET /region_types/new
  # GET /region_types/new.json
  def new
    @region_type = RegionType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @region_type }
    end
  end

  # GET /region_types/1/edit
  def edit
    @region_type = RegionType.find(params[:id])
  end

  # POST /region_types
  # POST /region_types.json
  def create
    @region_type = RegionType.new(params[:region_type])

    respond_to do |format|
      if @region_type.save
        format.html { redirect_to @region_type, notice: 'Region type was successfully created.' }
        format.json { render json: @region_type, status: :created, location: @region_type }
      else
        format.html { render action: "new" }
        format.json { render json: @region_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /region_types/1
  # PUT /region_types/1.json
  def update
    @region_type = RegionType.find(params[:id])

    respond_to do |format|
      if @region_type.update_attributes(params[:region_type])
        format.html { redirect_to @region_type, notice: 'Region type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @region_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /region_types/1
  # DELETE /region_types/1.json
  def destroy
    @region_type = RegionType.find(params[:id])
    @region_type.destroy

    respond_to do |format|
      format.html { redirect_to region_types_url }
      format.json { head :no_content }
    end
  end
end
