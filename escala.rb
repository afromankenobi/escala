require 'rubygems'
require 'sinatra'

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

class Array
  def chunk(size=2)
    chunks = []
    start = 0
    1.upto((self.length/size).ceil+1) do |i|
      last = start+size-1
      chunks << self[start..last] unless self[start..last].empty?
      start = last+1
    end
    chunks
  end
end

get '' do
redirect 'escala/'
end

get '/' do
  default_params = {:e => 60 , :p => 10, :s => 1, :m => 2}
  default_params.each{|k,v| params[k] = v if (!params[k] or params[k].empty?)}
  params.each{|k,v| params[k]=v.to_s.gsub(",",".").to_f}
  params[:e] = params[:e]/100.0
  params[:p] = 1000 if params[:p] > 1000
  params[:s] = 1.0 if params[:s] == 0
  params[:s] = 0.01 if params[:s] < 0.01
  @notas = (0..params[:p]/params[:s]).map{|p| [p*params[:s],nota(p*params[:s])]}
  @notas = @notas.chunk(15)

  params[:e] = params[:e]*100
  erb :escala
end

get '/stats' do
  @accesos = contar_accesos
  erb :accesos
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


def contar_accesos
  count = {}

  File::open('access.log', "r") do |f|
    f.read.split("\n").each do |l|
    l=l.gsub(/.*\[(.*)-..T.*\].*/,'\1')
    if l=~/\d{4}-\d{2}/
      if count[l].nil?
        count[l] = 1
      else
        count[l]+=1
      end
    end
  end
  return count.sort
  end
end
