<?php
class BasicCest
{    
    public function _before(AcceptanceTester $I)
    {
        $I->amOnPage('/');
    }

    public function clickOnCats(AcceptanceTester $I)
    {
        $I->see('Cats');
        $I->click('#cats');
        $I->see('My thoughts about Cats');
    }
}
