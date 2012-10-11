class OpportunityTypesController < ApplicationController
  # GET /opportunity_types
  # GET /opportunity_types.json
  def index
    @opportunity_types = OpportunityType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @opportunity_types }
    end
  end

  # GET /opportunity_types/1
  # GET /opportunity_types/1.json
  def show
    @opportunity_type = OpportunityType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @opportunity_type }
    end
  end

  # GET /opportunity_types/new
  # GET /opportunity_types/new.json
  def new
    @opportunity_type = OpportunityType.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @opportunity_type }
    end
  end

  # GET /opportunity_types/1/edit
  def edit
    @opportunity_type = OpportunityType.find(params[:id])
  end

  # POST /opportunity_types
  # POST /opportunity_types.json
  def create
    @opportunity_type = OpportunityType.new(params[:opportunity_type])

    respond_to do |format|
      if @opportunity_type.save
        format.html { redirect_to @opportunity_type, notice: 'Opportunity type was successfully created.' }
        format.json { render json: @opportunity_type, status: :created, location: @opportunity_type }
      else
        format.html { render action: "new" }
        format.json { render json: @opportunity_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /opportunity_types/1
  # PUT /opportunity_types/1.json
  def update
    @opportunity_type = OpportunityType.find(params[:id])

    respond_to do |format|
      if @opportunity_type.update_attributes(params[:opportunity_type])
        format.html { redirect_to @opportunity_type, notice: 'Opportunity type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @opportunity_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /opportunity_types/1
  # DELETE /opportunity_types/1.json
  def destroy
    @opportunity_type = OpportunityType.find(params[:id])
    @opportunity_type.destroy

    respond_to do |format|
      format.html { redirect_to opportunity_types_url }
      format.json { head :no_content }
    end
  end
end
