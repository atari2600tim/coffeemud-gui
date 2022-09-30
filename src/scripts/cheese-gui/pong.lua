function pong()
    echo("...Pong")
    echo(string.format("\nDelay of %.0fms\n",(1000*(getEpoch()-pingTime))))
end
