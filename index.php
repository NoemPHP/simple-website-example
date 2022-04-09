<?php

declare(strict_types=1);

use Noem\Http\ResponseEmitter;
use Psr\Container\ContainerInterface;
use Psr\EventDispatcher\EventDispatcherInterface;

use function Noem\Framework\bootstrap;

require 'vendor/autoload.php';
bootstrap(...require 'vendor/noem.php')(function (
    ContainerInterface $c,
    EventDispatcherInterface $d,
    ResponseEmitter $emitter
) {
    $requestEvent = $c->get('http.request.event');
    $d->dispatch($requestEvent);
    $emitter->emit($requestEvent->response());
})();

