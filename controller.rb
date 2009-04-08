require 'rubygems'
require 'sinatra'
require 'logger'

#e exigencia
#p puntaje máximo
#s step
#m nota mínima

module Rack
  class Request
    def ip
      if addr = @env['HTTP_X_FORWARDED_FOR']
        addr.split(',').last.strip
      else
        @env['REMOTE_ADDR']
      end
    end
  end
end


get '/' do
  Logger.new('access.log').info("Remote IP:#{request.ip}, URL:#{request.url}")
  default_params = {:e => 0.6, :p => 10, :s => 1, :m => 2}
  default_params.each{|k,v| params[k] = v if (!params[k] or params[k].empty?)}
  params.each{|k,v| params[k]=v.to_f}
  @notas = (0..params[:p]/params[:s]).map{|p| [p*params[:s],nota(p*params[:s])]}
  erb :escala
end

private

def nota(ptje) 
  if(ptje<params[:e]*params[:p])
    nota=(4-params[:m])*ptje/(params[:e]*params[:p])+params[:m] 
  else
    nota=3*(ptje-params[:e]*params[:p])/(params[:p]*(1-params[:e]))+4
  end
  return nota
end
