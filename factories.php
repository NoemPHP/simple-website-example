<?php

declare(strict_types=1);

use Noem\Container\Attribute\Tag;
use Noem\Http\Attribute\Route;
use Psr\Http\Message\ServerRequestInterface;

return [
    'acme.route.home' =>
        #[Route('/')]
        fn() => function () {
            echo <<<HTML
<html>
    <head></head>
    <body>
        <h1>Hello World, Noem here</h1>
        <ul>
            <li><a href="/Cats">Cats</a></li>
            <li><a href="/Dogs">Dogs</a></li>
            <li><a href="/Turtles">Turtles</a></li>
            <li><a href="/Goldfish">Goldfish</a></li>
        </ul>
       
    </body>
</html>
HTML;
        },
    'acme.route.page' =>
        #[Route('/{page}')]
        fn() => function (ServerRequestInterface $request) {
            echo <<<HTML
<html>
    <head></head>
    <body>
        <h1>My thoughts about {$request->getAttribute('page')}</h1>
        <p>The are pretty cool</p>
        <a href="/">Back to home</a>

    </body>
</html>
HTML;
        },
    'simple-exception-handler' =>
        #[Tag('exception-handler')]
        fn() => function (Throwable $e) {
            echo '<pre>' . var_dump($e, true) . '</pre>';
        }
];
