module Tests where

import Text.Parsec
import Text.Parsec.String
import Text.Parsec.Combinator
import Utils
import Paskell
import ExtraParsers
import KeywordParse

checkPass :: Parser a -> String -> Bool
checkPass p inp = case p' p inp of Right _ -> True
                                   Left  _ -> False
checkFail p inp = not $ checkPass p inp

test :: [(Parser a, Bool, String)] -> IO ()
test testcases = do
    let res = map (\(p, doPass, inp) -> (if doPass then checkPass else checkFail) p inp) testcases
    putStrLn $ "Running " ++ (show $ length res) ++ " tests:"
    mapM putStrLn $ (`map` (enumerate res))
        (\(i, x) -> 
            (show $ i+1) ++ (if x then "... OK" else "... FAILED"))
    putStrLn $ "Result: " ++ (show $ length $ filter id res) ++ "/" ++ (show $ length res) ++ " tests passed!"
    return ()

-- testParser parseIdent True ["X", "111"]

testParser p doPass xs = let tuple3 (a,b) c = (a,b,c) 
    in test $ zipWith tuple3 (repeat (p, doPass)) xs 

tparseIdent = do
    testParser parseIdent True [
        "X1",
        "x1",
        "x1  ",
        "Xyz1 ",
        "X1z  ",
        "xyz",
        "xYz  ",
        "X1@ ", -- should only consume X1
        "var123 " ]
    testParser parseIdent False [
        "",
        "1123",
        "1X1 ",
        " xyz",
        "Var" ]

tparseKeywords = do
    testParser parseKWand True [
        "and",
        "ANd",
        "and ",
        "ANd  \n " ]
    testParser parseKWand False [
        "and123",
        "sand" ]

tparseIdentList = do
    testParser parseIdentList True [
        "x,y",
        "x, y ",
        "x1 , y2 , Z ",
        "var1 , y2 , Z ",
        "x1 , y2 , Z" ]
    testParser parseIdentList False [
        "",
        "x1, var1, var",
        "x1, @, x2" ]
    
tparseVarDecl = do
    testParser parseVarDecl True [
        "var x,y:char;",
        "var x,y:char; ",
        "var x,y:char;abc",
        "var x , y : char ; abc",
        "var x,y:char; var1 , var2, var3: char ; abc",
        "var x,y:char; var" ]
    testParser parseVarDecl False [
        "var",
        "x,y:char;",
        "var x,var:char;",
        "var :char; x2:char;" ]

tparseTypeDecl = do
    testParser parseTypeDecl True [
        "type x,y=char;",
        "type x,y=char; ",
        "type x,y=char;abc",
        "type x , y = char ; abc",
        "type x,y=char; var1 , var2, var3= char ; abc",
        "type x,y=char; type",
        "type x,y=char; z=boolean; type w=char;abc " ]
    testParser parseTypeDecl False [
        "type",
        "x,y=char;",
        "type x,type=char;",
        "type =char; x2=char;" ]

tparseBlock = do
    testParser parseBlock True [
        "",
        "@abc ",
        "var x,y:char; z:boolean; var w:char;abc ",
        "var x,y:char; z:boolean; var w:char; abc",
        "var x,y:char; z:boolean; var w:char; type x,y=char; var1 , var2, var3= char ; abc",
        "var x , y : char ; z:boolean; var w:char; type x , y = char ; var1 , var2, var3= char ; abc ",
        "type x,y=char; z=boolean; type w=char;abc ",
        "type x,y=char; z=boolean; type w=char;" ++ "  type x,y=char; z=boolean; type w=char;" 
            ++ "var x2,y2:char; z2:boolean; var w2:char; abc" ]
    testParser parseBlock False [
        "type",
        "var",
        "var x=char;",
        "var x:char; type y:char;",
        "var x:char; type var=char;" ]

testAll = do
    tparseKeywords
    tparseIdent
    tparseIdentList
    tparseVarDecl
    tparseTypeDecl
    tparseBlock