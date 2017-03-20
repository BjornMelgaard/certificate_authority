class CertificatesController < ApplicationController
  before_action :set_certificate, only: [:show, :edit, :update, :destroy]

  # GET /certificates
  def index
    @certificates = Certificate.all
  end

  # GET /certificates/1
  def show
  end

  # GET /certificates/new
  def new
    @certificate = Certificate.new
  end

  # GET /certificates/1/edit
  def edit
  end

  # POST /certificates
  def create
    @certificate = Certificate.new(certificate_params)

    if @certificate.save
      redirect_to @certificate, notice: 'Certificate was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /certificates/1
  def update
    if @certificate.update(certificate_params)
      redirect_to @certificate, notice: 'Certificate was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /certificates/1
  def destroy
    @certificate.destroy
    redirect_to certificates_url, notice: 'Certificate was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_certificate
      @certificate = Certificate.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def certificate_params
      params.require(:certificate).permit(:cert, :serial)
    end
end
