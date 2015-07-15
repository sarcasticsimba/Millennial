mill:
	clang -Werror -Wall -framework Foundation -framework Appkit -o mill main.m

test:
	./mill testfiles/oprah.jpg ./testimg_oprah_meme.png You get a meme, you get a \
meme, ---- EVERYONE GETS A MEME!

test1:
	./mill testfiles/2.png ./testimg_med.png Upper text ---- Bottom text

test2:
	./mill testfiles/huge.png ./testimg_huge.png Words up top ---- Words down low

test_top:
	./mill testfiles/2.png ./testimg_just_top.png Just top text ---- _

test_top_short:
	./mill testfiles/2.png ./testimg_short_top.png V ---- _

test_bot:
	./mill testfiles/2.png ./testimg_just_bot.png _ ---- Just bottom text

test_bot_short:
	./mill testfiles/2.png ./testimg_short_bot.png _ ---- V

no_caption:
	./mill testfiles/2.png ./testimg_no_caption.png _ ---- _

run:
	make test; make test1; make test2; make test_top; make test_top_short;
	make test_bot; make test_bot_short; make no_caption

clean:
	rm mill
	rm testimg*.png
